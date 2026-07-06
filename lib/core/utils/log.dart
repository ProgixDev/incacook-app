import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight ANSI-coloured logger routed through `dart:developer.log`, so
/// entries are grouped under the `IncaCook` source (with a timestamp) in the
/// debug console and DevTools — far easier to scan than raw `debugPrint`.
///
/// Mirrors the helper used in the `suich-drive` app. Four levels, each a
/// distinct colour. Keep the existing tag convention in the message, e.g.
///
///   logInfo('[RevenueCat] configured=$ok');
///   logSuccess('[RevenueCat] sdk configured success=true');
///   logWarning('[Subscription] no active entitlement');
///   logError('[RevenueCat] getOfferings failed: $e');
///
/// Output is suppressed in release/profile builds (debug-only), so these are
/// safe to leave in shipping code.

/// Toggle the `:mm:ss:ms` suffix on the source name.
bool showLogTime = true;

String get _printTime {
  final d = DateTime.now();
  return showLogTime ? ':${d.minute}:${d.second}:${d.millisecond}' : '';
}

void _emit(String colorCode, Object? msg) {
  if (!kDebugMode) return;
  developer.log('\x1B[${colorCode}m$msg\x1B[0m', name: 'IncaCook$_printTime');
}

/// Blue — general information / flow tracing.
void logInfo(Object? msg) => _emit('34', msg);

/// Green — a successful, noteworthy outcome.
void logSuccess(Object? msg) => _emit('32', msg);

/// Yellow — recoverable / unexpected-but-handled conditions.
void logWarning(Object? msg) => _emit('33', msg);

/// Red — failures and errors.
void logError(Object? msg) => _emit('31', msg);
