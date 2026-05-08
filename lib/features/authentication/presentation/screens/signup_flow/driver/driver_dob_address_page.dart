import 'package:flutter/material.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/seller/seller_dob_address_page.dart';

/// Driver and seller share the same DOB + pickup-address shape, so this
/// page just delegates to [SellerDobAddressPage]. Keep them as distinct
/// types so the dynamic page list can address them separately.
class DriverDobAddressPage extends StatelessWidget {
  const DriverDobAddressPage({super.key});

  @override
  Widget build(BuildContext context) => const SellerDobAddressPage();
}
