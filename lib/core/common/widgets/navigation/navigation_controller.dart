import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/navigation/nav_tab.dart';

class NavigationController extends GetxController {
  NavigationController({required this.tabs});

  final List<NavTab> tabs;
  final Rx<int> selectedIndex = 0.obs;
}
