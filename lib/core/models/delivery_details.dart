import 'package:incacook/core/models/address.dart';

enum DeliveryTiming { asap, scheduled }

class DeliveryDetails {
  const DeliveryDetails({
    required this.address,
    required this.instructions,
    required this.timing,
    this.scheduledAt,
  });

  final Address address;
  final String instructions;
  final DeliveryTiming timing;
  final DateTime? scheduledAt;
}
