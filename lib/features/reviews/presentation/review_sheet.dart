import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/reviews/data/reviews_repository.dart';

/// Bottom sheet for a buyer to review a DELIVERED order. Submits to
/// `POST /v1/orders/:id/review`. Pops `true` on success so the caller can
/// refresh + confirm. Hygiene is binary (Bonne = 100 / Mauvaise = 0);
/// quality + packaging are 1–5.
class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key, required this.orderId, this.orderNumber});

  final String orderId;
  final String? orderNumber;

  /// Opens the sheet; resolves to `true` when a review was submitted.
  static Future<bool?> show(
    BuildContext context, {
    required String orderId,
    String? orderNumber,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReviewSheet(orderId: orderId, orderNumber: orderNumber),
    );
  }

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _rating = 0;
  bool _hygieneGood = true;
  int _foodQuality = 5;
  int _packaging = 5;
  final TextEditingController _comment = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      setState(() => _error = 'Donne une note globale (1 à 5 étoiles).');
      return;
    }
    if (_comment.text.trim().isEmpty) {
      setState(() => _error = 'Ajoute un commentaire.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ReviewsRepository().submit(
        orderId: widget.orderId,
        rating: _rating,
        body: _comment.text.trim(),
        hygiene: _hygieneGood ? 100 : 0,
        foodQuality: _foodQuality,
        packaging: _packaging,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      // Lift above the keyboard when the comment field is focused.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.md,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(AppSizes.md),
            Text(
              widget.orderNumber == null
                  ? 'Noter votre commande'
                  : 'Noter la commande #${widget.orderNumber}',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Gap(AppSizes.lg),

            //* overall rating (required)
            _Label('Note globale'),
            const Gap(AppSizes.sm),
            _StarInput(value: _rating, onChanged: (v) => setState(() => _rating = v)),
            const Gap(AppSizes.lg),

            //* hygiene — binary
            _Label('Hygiène'),
            const Gap(AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'Bonne',
                    icon: Iconsax.like_1,
                    selected: _hygieneGood,
                    onTap: () => setState(() => _hygieneGood = true),
                  ),
                ),
                const Gap(AppSizes.sm),
                Expanded(
                  child: _ChoiceButton(
                    label: 'Mauvaise',
                    icon: Iconsax.dislike,
                    selected: !_hygieneGood,
                    onTap: () => setState(() => _hygieneGood = false),
                  ),
                ),
              ],
            ),
            const Gap(AppSizes.lg),

            //* food quality 1–5
            _Label('Qualité du plat'),
            const Gap(AppSizes.sm),
            _StarInput(
              value: _foodQuality,
              onChanged: (v) => setState(() => _foodQuality = v),
            ),
            const Gap(AppSizes.lg),

            //* packaging 1–5
            _Label('Emballage'),
            const Gap(AppSizes.sm),
            _StarInput(
              value: _packaging,
              onChanged: (v) => setState(() => _packaging = v),
            ),
            const Gap(AppSizes.lg),

            //* comment (required)
            _Label('Commentaire'),
            const Gap(AppSizes.sm),
            TextField(
              controller: _comment,
              maxLines: 3,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Partagez votre expérience…',
              ),
            ),

            if (_error != null) ...[
              const Gap(AppSizes.sm),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
            const Gap(AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _StarInput extends StatelessWidget {
  const _StarInput({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: Icon(
              filled ? Iconsax.star1 : Iconsax.star,
              size: 32,
              color: filled
                  ? const Color(0xFFFFC107)
                  : scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        );
      }),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            const Gap(AppSizes.sm),
            Text(
              label,
              style: TextStyle(
                color: selected ? scheme.onPrimary : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
