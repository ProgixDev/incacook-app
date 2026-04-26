import 'package:get/get.dart';
import 'package:homemade/features/chat/presentation/screens/chat_list.dart';
import 'package:homemade/features/home/presentation/screens/home.dart';
import 'package:homemade/features/profile/presentation/screens/settings.dart';

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    // const Center(child: Text("Cart Screen")),
    const ChatListScreen(),
    const SettingsScreen(),
  ];
}
