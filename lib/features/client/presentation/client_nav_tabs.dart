import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/navigation/nav_tab.dart';
import 'package:incacook/features/chat/presentation/screens/conversations_list.dart';
import 'package:incacook/features/client/presentation/screens/client_home.dart';
import 'package:incacook/features/settings/presentation/screens/settings.dart';

const List<NavTab> kClientNavTabs = [
  NavTab(icon: Iconsax.home, label: 'Accueil', screen: ClientHomeScreen()),
  // Real conversations (seller + livreur + support) — peer name, avatar,
  // last message, time and unread count come from the backend.
  NavTab(
    icon: Iconsax.message,
    label: 'Messages',
    screen: ConversationsListScreen(showBackArrow: false),
  ),
  NavTab(icon: Iconsax.user, label: 'Profil', screen: SettingsScreen()),
];
