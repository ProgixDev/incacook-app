import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/navigation/nav_tab.dart';
import 'package:homemade/features/chat/presentation/screens/chat_list.dart';
import 'package:homemade/features/client/presentation/screens/client_home.dart';
import 'package:homemade/features/settings/presentation/screens/settings.dart';

const List<NavTab> kClientNavTabs = [
  NavTab(icon: Iconsax.home, label: 'Accueil', screen: ClientHomeScreen()),
  NavTab(icon: Iconsax.message, label: 'Messages', screen: ChatListScreen()),
  NavTab(icon: Iconsax.user, label: 'Profil', screen: SettingsScreen()),
];
