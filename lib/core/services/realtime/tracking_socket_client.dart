import 'dart:async';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/core/services/realtime/delivery_cancelled_event.dart';
import 'package:incacook/core/services/realtime/driver_location.dart';
import 'package:incacook/core/services/realtime/order_status_event.dart';

/// Singleton client over the `/tracking` Socket.IO namespace. Three
/// kinds of subscriptions over one physical socket:
///   * order  → driver location + order status (one room per order)
///   * conversation → persisted chat messages   (one room per conv)
/// Rooms are addressed server-side; this class just multiplexes
/// listeners onto broadcast streams and re-subscribes after reconnect.
class TrackingSocketClient extends GetxService {
  TrackingSocketClient({TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? Get.find<TokenStorage>();

  static TrackingSocketClient get instance => Get.find();

  final TokenStorage _tokenStorage;
  final _log = Logger(printer: SimplePrinter(printTime: true));

  sio.Socket? _socket;
  Future<sio.Socket>? _connecting;

  // Per-order broadcast streams. Many widgets may listen to the same
  // order; we multiplex onto one server room each.
  final Map<String, StreamController<DriverLocation>> _locControllers = {};
  final Map<String, StreamController<OrderStatusEvent>> _statusControllers = {};

  // Conversation message streams keyed by Conversation.id (the DB
  // primary key — the server room is `conv:<id>`).
  final Map<String, StreamController<Message>> _convControllers = {};
  final Set<String> _pendingConvIds = <String>{};

  // Maps the server's resolved deliveryId back to the orderId we
  // subscribed with, so incoming `driver:location` events route to the
  // right location controller.
  final Map<String, String> _deliveryToOrder = {};

  // Pending order subscriptions waiting for the socket to be
  // (re)connected.
  final Set<String> _pendingOrderIds = <String>{};

  // Per-user `delivery:cancelled` events. The server auto-joins the socket to
  // the user's room on connect, so no explicit subscribe is needed — listeners
  // just need a live connection.
  StreamController<DeliveryCancelledEvent>? _cancelController;

  /// Broadcast stream of driver positions for [orderId]. Empty for
  /// pickup orders (no driver). The first listener triggers a
  /// `subscribe` emit; later listeners share the same stream.
  Stream<DriverLocation> subscribeToOrder(String orderId) {
    final existing = _locControllers[orderId];
    if (existing != null) return existing.stream;

    final controller = StreamController<DriverLocation>.broadcast();
    _locControllers[orderId] = controller;
    _ensureStatusControllerExists(orderId);
    _pendingOrderIds.add(orderId);
    unawaited(_ensureConnectedAndSubscribe(orderId));
    return controller.stream;
  }

  /// Broadcast stream of status transitions for [orderId]. Fires on
  /// CONFIRMED → PREPARING → READY → IN_DELIVERY → DELIVERED, etc.
  Stream<OrderStatusEvent> subscribeToOrderStatus(String orderId) {
    final controller = _ensureStatusControllerExists(orderId);
    _pendingOrderIds.add(orderId);
    unawaited(_ensureConnectedAndSubscribe(orderId));
    return controller.stream;
  }

  /// Broadcast stream of chat messages for the persisted conversation
  /// [conversationId]. The server verifies the caller is a participant
  /// (via ConversationParticipant) and joins them to `conv:<id>`;
  /// every party (sender included) receives the `message:new` echo.
  Stream<Message> subscribeToConversation(String conversationId) {
    final controller = _convControllers.putIfAbsent(
      conversationId,
      () => StreamController<Message>.broadcast(),
    );
    _pendingConvIds.add(conversationId);
    unawaited(_ensureConnectedAndSubscribeConv(conversationId));
    return controller.stream;
  }

  /// Broadcast stream of `delivery:cancelled` events targeted at the current
  /// user (e.g. the assigned driver). Opening the stream ensures a live socket
  /// so the server's per-user room delivers the event — no explicit subscribe.
  Stream<DeliveryCancelledEvent> deliveryCancellations() {
    final controller =
        _cancelController ??= StreamController<DeliveryCancelledEvent>.broadcast();
    unawaited(
      _ensureConnected().then(
        (_) {},
        onError: (Object e) => _log.w('[tracking] delivery-cancel connect failed: $e'),
      ),
    );
    return controller.stream;
  }

  Future<void> _ensureConnectedAndSubscribeConv(String conversationId) async {
    try {
      final socket = await _ensureConnected();
      _emitConvSubscribe(socket, conversationId);
    } catch (e) {
      _log.w('[tracking] conv subscribe failed for $conversationId: $e');
      final ctl = _convControllers[conversationId];
      if (ctl != null && !ctl.isClosed) ctl.addError(e);
    }
  }

  void _emitConvSubscribe(sio.Socket socket, String conversationId) {
    socket.emitWithAck(
      'conv:subscribe',
      {'conversationId': conversationId},
      ack: (resp) {
        try {
          if (resp is Map && resp['ok'] == true) {
            _pendingConvIds.remove(conversationId);
            _log.d('[tracking] conv subscribed id=$conversationId');
            return;
          }
          _log.w('[tracking] conv:subscribe NACK $conversationId: $resp');
          _convControllers[conversationId]?.addError(
            StateError('conv subscribe rejected: $resp'),
          );
        } catch (e) {
          _log.w('[tracking] conv:subscribe ack handler threw: $e');
        }
      },
    );
  }

  /// Stops receiving messages for [conversationId].
  Future<void> unsubscribeFromConversation(String conversationId) async {
    final ctl = _convControllers.remove(conversationId);
    _pendingConvIds.remove(conversationId);
    if (ctl != null && !ctl.isClosed) await ctl.close();
    final socket = _socket;
    if (socket != null && socket.connected) {
      socket.emit('conv:unsubscribe', {'conversationId': conversationId});
    }
  }

  StreamController<OrderStatusEvent> _ensureStatusControllerExists(String orderId) {
    return _statusControllers.putIfAbsent(
      orderId,
      () => StreamController<OrderStatusEvent>.broadcast(),
    );
  }

  /// Stops receiving events for [orderId] and closes the per-order
  /// location + status streams.
  Future<void> unsubscribeFromOrder(String orderId) async {
    final loc = _locControllers.remove(orderId);
    final st = _statusControllers.remove(orderId);
    _pendingOrderIds.remove(orderId);
    _deliveryToOrder.removeWhere((_, oid) => oid == orderId);
    if (loc != null && !loc.isClosed) await loc.close();
    if (st != null && !st.isClosed) await st.close();
    final socket = _socket;
    if (socket != null && socket.connected) {
      socket.emit('unsubscribe', {'orderId': orderId});
    }
  }

  /// Drops the socket and clears every subscription. Call on logout.
  Future<void> disposeAll() async {
    for (final c in _locControllers.values) {
      if (!c.isClosed) await c.close();
    }
    for (final c in _statusControllers.values) {
      if (!c.isClosed) await c.close();
    }
    for (final c in _convControllers.values) {
      if (!c.isClosed) await c.close();
    }
    final cancelCtl = _cancelController;
    if (cancelCtl != null && !cancelCtl.isClosed) await cancelCtl.close();
    _cancelController = null;
    _locControllers.clear();
    _statusControllers.clear();
    _convControllers.clear();
    _pendingConvIds.clear();
    _pendingOrderIds.clear();
    _deliveryToOrder.clear();
    _socket?.dispose();
    _socket = null;
    _connecting = null;
  }

  Future<sio.Socket> _ensureConnected() async {
    final existing = _socket;
    if (existing != null && existing.connected) return existing;
    final inFlight = _connecting;
    if (inFlight != null) return inFlight;

    final completer = Completer<sio.Socket>();
    _connecting = completer.future;

    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      _connecting = null;
      completer.completeError(StateError('no access token for socket'));
      return completer.future;
    }

    final uri = '${ApiConstants.baseUrl}/tracking';
    final socket = sio.io(
      uri,
      sio.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .enableReconnection()
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .build(),
    );

    socket.onConnect((_) {
      _log.d('[tracking] connected ${socket.id}');
      final toResub = <String>{
        ..._pendingOrderIds,
        ..._locControllers.keys,
        ..._statusControllers.keys,
      };
      for (final orderId in toResub) {
        _emitSubscribe(socket, orderId);
      }
      final convResub = <String>{
        ..._pendingConvIds,
        ..._convControllers.keys,
      };
      for (final convId in convResub) {
        _emitConvSubscribe(socket, convId);
      }
      if (!completer.isCompleted) completer.complete(socket);
    });

    socket.onConnectError((err) {
      _log.w('[tracking] connect error: $err');
      if (!completer.isCompleted) completer.completeError(err ?? 'connect error');
    });
    socket.onError((err) => _log.w('[tracking] socket error: $err'));
    socket.onDisconnect((_) => _log.d('[tracking] disconnected'));

    socket.on('driver:location', (data) {
      if (data is! Map) return;
      try {
        final payload = Map<String, dynamic>.from(data);
        final ev = DriverLocation.fromJson(payload);
        final orderId = _deliveryToOrder[ev.deliveryId];
        if (orderId == null) return;
        _locControllers[orderId]?.add(ev);
      } catch (e) {
        _log.w('[tracking] bad driver:location payload: $e');
      }
    });

    socket.on('order:status', (data) {
      if (data is! Map) return;
      try {
        final payload = Map<String, dynamic>.from(data);
        final ev = OrderStatusEvent.fromJson(payload);
        _statusControllers[ev.orderId]?.add(ev);
      } catch (e) {
        _log.w('[tracking] bad order:status payload: $e');
      }
    });

    socket.on('message:new', (data) {
      if (data is! Map) return;
      try {
        final payload = Map<String, dynamic>.from(data);
        final msg = Message.fromJson(payload);
        _convControllers[msg.conversationId]?.add(msg);
      } catch (e) {
        _log.w('[tracking] bad message:new payload: $e');
      }
    });

    socket.on('delivery:cancelled', (data) {
      if (data is! Map) return;
      try {
        final payload = Map<String, dynamic>.from(data);
        _cancelController?.add(DeliveryCancelledEvent.fromJson(payload));
      } catch (e) {
        _log.w('[tracking] bad delivery:cancelled payload: $e');
      }
    });

    _socket = socket;
    socket.connect();
    return completer.future;
  }

  Future<void> _ensureConnectedAndSubscribe(String orderId) async {
    try {
      final socket = await _ensureConnected();
      _emitSubscribe(socket, orderId);
    } catch (e) {
      _log.w('[tracking] subscribe failed for $orderId: $e');
      final loc = _locControllers[orderId];
      if (loc != null && !loc.isClosed) loc.addError(e);
      final st = _statusControllers[orderId];
      if (st != null && !st.isClosed) st.addError(e);
    }
  }

  void _emitSubscribe(sio.Socket socket, String orderId) {
    socket.emitWithAck('subscribe', {'orderId': orderId}, ack: (resp) {
      try {
        if (resp is Map) {
          final ok = resp['ok'] == true;
          final ackedOrderId = resp['orderId'] as String? ?? orderId;
          final deliveryId = resp['deliveryId'] as String?;
          if (ok) {
            if (deliveryId != null) {
              _deliveryToOrder[deliveryId] = ackedOrderId;
            }
            _pendingOrderIds.remove(orderId);
            _log.d(
              '[tracking] subscribed order=$ackedOrderId delivery=${deliveryId ?? "(none)"}',
            );
            return;
          }
        }
        _log.w('[tracking] subscribe NACK for $orderId: $resp');
        _locControllers[orderId]?.addError(StateError('subscribe rejected: $resp'));
        _statusControllers[orderId]?.addError(StateError('subscribe rejected: $resp'));
      } catch (e) {
        _log.w('[tracking] subscribe ack handler threw: $e');
      }
    });
  }
}