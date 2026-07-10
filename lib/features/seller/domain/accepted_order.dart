enum AcceptedOrderStatus { awaitingAccept, readyToPickup, preparing, completed, cancelled }

class AcceptedOrder {
  const AcceptedOrder({
    required this.id,
    required this.acceptedAt,
    required this.status,
    required this.minutesRemaining,
    required this.totalPrice,
  });

  final String id;
  final DateTime acceptedAt;
  final AcceptedOrderStatus status;
  final int minutesRemaining;
  final double totalPrice;
}