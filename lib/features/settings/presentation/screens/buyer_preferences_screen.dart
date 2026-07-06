import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/models/requests/buyer_preferences_request.dart';
import 'package:incacook/features/authentication/data/repositories/buyers_repository.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_chip_group.dart';

/// Lets a buyer edit their dietary preferences + allergens after signup
/// (`PUT /v1/buyers/me/preferences`), then refreshes the global user cache so
/// the feed / filtering reflects the change. Reuses the signup chip UI.
class BuyerPreferencesScreen extends StatefulWidget {
  const BuyerPreferencesScreen({super.key});

  @override
  State<BuyerPreferencesScreen> createState() => _BuyerPreferencesScreenState();
}

class _BuyerPreferencesScreenState extends State<BuyerPreferencesScreen> {
  late final List<DietaryTag> _dietary;
  late final List<Allergen> _allergens;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final ba = UserController.instance.user.value?.buyerAccount;
    _dietary = List<DietaryTag>.of(ba?.dietaryTags ?? const []);
    _allergens = List<Allergen>.of(ba?.allergens ?? const []);
  }

  void _toggleDietary(DietaryTag d) => setState(() {
        if (_dietary.contains(d)) {
          _dietary.remove(d);
        } else {
          _dietary.add(d);
        }
      });

  void _toggleAllergen(Allergen a) => setState(() {
        if (_allergens.contains(a)) {
          _allergens.remove(a);
        } else {
          _allergens.add(a);
        }
      });

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await BuyersRepository.instance.setPreferences(
        BuyerPreferencesRequest(dietaryTags: _dietary, allergens: _allergens),
      );
      await UserController.instance.refreshFromServer();
      if (!mounted) return;
      Get.back<void>();
      Get.snackbar(
        AppTexts.profileActionPreferences,
        'Préférences mises à jour',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Échec de la mise à jour: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.profileActionPreferences,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.signupBuyerDietaryDietSection,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(AppSizes.sm + 4),
              SignupChipGroup<DietaryTag>(
                options: DietaryTag.values,
                selected: _dietary,
                labelOf: (d) => d.label,
                leadingOf: (d) => Image.asset(d.iconPath),
                onToggle: _toggleDietary,
              ),
              const Gap(AppSizes.lg),
              Text(
                AppTexts.signupBuyerDietaryAllergiesSection,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(AppSizes.xs),
              Text(
                AppTexts.signupBuyerDietaryAllergiesHint,
                style: textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Gap(AppSizes.sm + 4),
              SignupChipGroup<Allergen>(
                options: Allergen.values,
                selected: _allergens,
                labelOf: (a) => a.label,
                onToggle: _toggleAllergen,
              ),
              if (_error != null) ...[
                const Gap(AppSizes.md),
                Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ],
              const Gap(AppSizes.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
