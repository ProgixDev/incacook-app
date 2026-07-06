import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/bindings/general_bindings.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/utils/theme/theme.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_binding.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/signup_shell_screen.dart';
import 'package:incacook/features/bootstrap/presentation/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeController.mode.value,
        theme: CustomAppTheme.lightTheme,
        darkTheme: CustomAppTheme.darkTheme,
        initialBinding: GeneralBindings(),
        builder: (context, child) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final scope = FocusScope.of(context);
            if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
              scope.unfocus();
            }
          },
          child: _KeyboardDismissOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        getPages: [
          GetPage<void>(
            name: '/signup',
            page: () => const SignupShellScreen(),
            binding: SignupFlowBinding(),
            transition: Transition.fadeIn,
          ),
        ],
        // Safety net: an unmatched route (e.g. an OAuth callback deep link
        // that slips through to the router) lands on the splash, which
        // re-bootstraps — instead of GetX null-crashing in route middleware.
        unknownRoute: GetPage<void>(
          name: '/_unknown',
          page: () => const SplashScreen(),
        ),
        // Splash hands off to OnBoarding / Welcome / role home / resumed
        // signup based on stored session + /users/me/onboarding.
        home: const SplashScreen(),
      ),
    );
  }
}

class _KeyboardDismissOverlay extends StatefulWidget {
  const _KeyboardDismissOverlay({required this.child});

  final Widget child;

  @override
  State<_KeyboardDismissOverlay> createState() =>
      _KeyboardDismissOverlayState();
}

class _KeyboardDismissOverlayState extends State<_KeyboardDismissOverlay> {
  bool _hasEditableFocus = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusChange);
    _handleFocusChange();
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    final hasFocus = FocusManager.instance.primaryFocus != null;
    if (hasFocus != _hasEditableFocus && mounted) {
      setState(() => _hasEditableFocus = hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final visible = keyboardInset > 0 && _hasEditableFocus;

    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          right: 16,
          bottom: visible ? keyboardInset + 12 : 12,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: visible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !visible,
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(18),
                elevation: 6,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      'OK',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
