enum FulfillmentChoice { delivery, pickup }

class FulfillmentOptions {
  const FulfillmentOptions({
    required this.deliveryAvailable,
    required this.deliveryMinMinutes,
    required this.deliveryMaxMinutes,
    required this.deliveryFee,
    required this.pickupAvailable,
    required this.pickupNeighborhood,
    this.userHasAddress = true,
  });

  final bool deliveryAvailable;
  final int deliveryMinMinutes;
  final int deliveryMaxMinutes;
  final double deliveryFee;
  final bool pickupAvailable;
  final String pickupNeighborhood;
  final bool userHasAddress;

  bool get deliverySelectable => deliveryAvailable && userHasAddress;
}

class FulfillmentSelection {
  const FulfillmentSelection({required this.choice, required this.fee});

  final FulfillmentChoice choice;
  final double fee;
}
