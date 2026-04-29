import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/bindings/general_bindings.dart';
import 'package:homemade/core/controllers/theme_controller.dart';
import 'package:homemade/core/utils/theme/theme.dart';
import 'package:homemade/features/delivery/presentation/screens/delivery_home.dart';
import 'package:homemade/features/onboarding/presentation/screens/onboarding.dart';

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
        home: kDebugMode
            ? const DeliveryHomeScreen()
            : const OnBoardingScreen(),
      ),
    );
  }
}
