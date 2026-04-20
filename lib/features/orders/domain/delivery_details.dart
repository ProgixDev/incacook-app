import 'package:vinted_v2/features/orders/domain/saved_address.dart';

enum DeliveryTiming { asap, scheduled }

class DeliveryDetails {
  const DeliveryDetails({
    required this.address,
    required this.instructions,
    required this.timing,
    this.scheduledAt,
  });

  final SavedAddress address;
  final String instructions;
  final DeliveryTiming timing;
  final DateTime? scheduledAt;
}
