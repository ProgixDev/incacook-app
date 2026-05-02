class OrderRequest {
  const OrderRequest({
    required this.id,
    required this.placedAt,
    required this.items,
    required this.note,
    required this.paymentStatus,
    required this.deliverTo,
  });

  final String id;
  final DateTime placedAt;
  final List<OrderRequestItem> items;
  final String note;
  final String paymentStatus;
  final String deliverTo;
}

class OrderRequestItem {
  const OrderRequestItem({
    required this.name,
    required this.price,
    required this.portion,
    required this.quantity,
    this.isVeg = true,
  });

  final String name;
  final double price;
  final String portion;
  final int quantity;
  final bool isVeg;
}
