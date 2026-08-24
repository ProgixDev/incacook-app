import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';

class SocialButtons extends StatelessWidget {
  SocialButtons({
    super.key,
    this.onGoogle,
    this.onFacebook,
    this.onApple,
    this.showGoogle = true,
    this.showFacebook = true,
    bool? showApple,
  }) : showApple = showApple ?? (!kIsWeb && _isIOS);

  /// Tap handlers for the provider buttons. Optional so existing callers
  /// that only want the decorative row keep working; the login screen
  /// passes the [WelcomeController] flows.
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final VoidCallback? onApple;
  final bool showGoogle;
  final bool showFacebook;

  /// Apple Sign-In defaults to iOS-only (#53 / guideline 4.8 applies most
  /// strictly there) — pass an explicit value to override.
  final bool showApple;

  static bool get _isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (showGoogle)
        _SocialButton(logo: AppImages.googleLogo, onTap: onGoogle),
      if (showFacebook)
        _SocialButton(logo: AppImages.facebookLogo, onTap: onFacebook),
      if (showApple)
        _SocialButton(
          icon: Icons.apple,
          onTap: onApple,
        ),
    ];

    if (buttons.isEmpty) return const SizedBox.shrink();

    final spacedButtons = <Widget>[];
    for (final button in buttons) {
      if (spacedButtons.isNotEmpty) {
        spacedButtons.add(const Gap(AppSizes.spaceBtwItems));
      }
      spacedButtons.add(button);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: spacedButtons,
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({this.logo, this.icon, required this.onTap})
      : assert(
          logo != null || icon != null,
          'Provide either a logo asset or an icon.',
        );

  /// Asset path for a provider logo image (Google, Facebook).
  final String? logo;

  /// Material glyph for a provider without a bundled asset (Apple's
  /// system glyph, per Apple's Human Interface Guidelines).
  final IconData? icon;

  // Nullable: a null `onTap` disables (and dims) the button — used while a
  // social login is already running to block double / simultaneous launches.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1.0,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.sm + 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: icon != null
                ? Icon(icon, size: AppSizes.iconMd, color: Colors.black)
                : Image(
                    image: AssetImage(logo!),
                    height: AppSizes.iconMd,
                    width: AppSizes.iconMd,
                  ),
          ),
        ),
      ),
    );
  }
}
