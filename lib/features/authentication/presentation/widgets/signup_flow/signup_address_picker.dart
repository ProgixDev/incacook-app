import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/data/models/address.dart';
import 'package:incacook/features/authentication/data/repositories/signup_repository.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

/// Stubbed address autocomplete. Wired to [SignupRepository.searchAddresses]
/// — replace with the real Mapbox geocoding response when the integration
/// lands.
class SignupAddressPicker extends StatefulWidget {
  const SignupAddressPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint = AppTexts.signupAddressSearchHint,
  });

  final Address? value;
  final ValueChanged<Address?> onChanged;
  final String hint;

  @override
  State<SignupAddressPicker> createState() => _SignupAddressPickerState();
}

class _SignupAddressPickerState extends State<SignupAddressPicker> {
  final _repository = Get.find<SignupRepository>();
  late final TextEditingController _controller;
  List<String> _suggestions = const [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.fullAddress ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChangedQuery(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _suggestions = const []);
      widget.onChanged(null);
      return;
    }
    setState(() => _searching = true);
    final results = await _repository.searchAddresses(q);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _searching = false;
    });
  }

  void _select(String suggestion) {
    final city = suggestion.split(',').last.trim().split(' ').last;
    final postalMatch = RegExp(r'\b(\d{5})\b').firstMatch(suggestion);
    final postal = postalMatch?.group(1) ?? '';
    final address = Address(
      fullAddress: suggestion,
      city: city,
      postalCode: postal,
      latitude: 48.8566,
      longitude: 2.3522,
    );
    _controller.text = suggestion;
    setState(() => _suggestions = const []);
    widget.onChanged(address);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignupTextField(
          controller: _controller,
          hint: widget.hint,
          leadingIcon: Iconsax.location,
          onChanged: _onChangedQuery,
          trailing: _searching
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.sm + 4),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        if (_suggestions.isNotEmpty) ...[
          const Gap(AppSizes.sm),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: _suggestions
                  .map(
                    (s) => InkWell(
                      onTap: () => _select(s),
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusLg,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.sm + 4),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.location,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                            const Gap(AppSizes.sm + 4),
                            Expanded(
                              child: Text(
                                s,
                                style: TextStyle(color: scheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (widget.value != null) ...[
          const Gap(AppSizes.sm + 4),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              border: Border.all(color: scheme.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.location_tick, color: scheme.primary, size: 32),
                const Gap(AppSizes.xs + 2),
                Text(
                  AppTexts.signupAddressConfirmed,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
