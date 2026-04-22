import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/bindings/general_bindings.dart';
import 'package:vinted_v2/core/utils/theme/theme.dart';
import 'package:vinted_v2/features/onboarding/presentation/screens/onboarding.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: CustomAppTheme.lightTheme,
      darkTheme: CustomAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      home: const OnBoardingScreen(),
    );
  }
}
