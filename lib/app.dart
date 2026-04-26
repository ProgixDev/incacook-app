import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/bindings/general_bindings.dart';
import 'package:homemade/core/common/widgets/navigation/navigation_menu.dart';
import 'package:homemade/core/utils/theme/theme.dart';
import 'package:homemade/features/authentication/presentation/screens/welcome.dart';
import 'package:homemade/features/onboarding/presentation/screens/onboarding.dart';

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
      home: OnBoardingScreen(),
    );
  }
}
