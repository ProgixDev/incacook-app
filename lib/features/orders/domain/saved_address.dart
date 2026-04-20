import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

enum SavedAddressType {
  home(label: AppTexts.addressTypeHome, icon: Iconsax.home_2),
  work(label: AppTexts.addressTypeWork, icon: Iconsax.briefcase),
  other(label: AppTexts.addressTypeOther, icon: Iconsax.location);

  const SavedAddressType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.type,
    required this.line1,
    required this.line2,
    this.customLabel,
    this.inRange = true,
  });

  final String id;
  final SavedAddressType type;
  final String line1;
  final String line2;
  final String? customLabel;
  final bool inRange;

  String get label => customLabel ?? type.label;
}
