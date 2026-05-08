import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/bindings/general_bindings.dart';
import 'package:incacook/core/common/widgets/navigation/navigation_menu.dart';
import 'package:incacook/core/controllers/theme_controller.dart';
import 'package:incacook/core/utils/theme/theme.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_binding.dart';
import 'package:incacook/features/authentication/presentation/screens/signup_flow/signup_shell_screen.dart';
import 'package:incacook/features/client/presentation/client_nav_tabs.dart';
import 'package:incacook/features/delivery/presentation/screens/delivery_home.dart';
import 'package:incacook/features/onboarding/presentation/screens/onboarding.dart';
import 'package:incacook/features/seller/presentation/screens/seller_home.dart';
import 'package:incacook/features/seller/presentation/seller_nav_tabs.dart';

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
        getPages: [
          GetPage<void>(
            name: '/signup',
            page: () => const SignupShellScreen(),
            binding: SignupFlowBinding(),
            transition: Transition.fadeIn,
          ),
        ],
        home: const OnBoardingScreen(),
      ),
    );
  }
}
