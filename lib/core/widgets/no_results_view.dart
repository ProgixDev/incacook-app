import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

import 'package:incacook/core/constants/sizes.dart';

/// Empty-state placeholder built around the shared `no_result` Lottie. Use
/// wherever a list/section comes back empty (feed, kitchens, search, …).
class NoResultsView extends StatelessWidget {
  const NoResultsView({super.key, this.message, this.size = 150});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/no_result.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          if (message != null) ...[
            const Gap(AppSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
