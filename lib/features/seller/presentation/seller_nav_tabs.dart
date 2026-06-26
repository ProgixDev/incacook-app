import 'package:incacook/core/common/widgets/navigation/nav_tab.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/features/chat/presentation/screens/conversations_list.dart';
import 'package:incacook/features/seller/presentation/screens/order_requests.dart';
import 'package:incacook/features/seller/presentation/screens/seller_home.dart';
import 'package:incacook/features/seller/presentation/screens/seller_products.dart';
import 'package:incacook/features/settings/presentation/screens/settings.dart';
import 'package:incacook/features/subscriptions/presentation/widgets/subscription_gate.dart';
import 'package:iconsax/iconsax.dart';

// Seller feature tabs are wrapped in [SubscriptionGate]: when the $4/mo
// platform subscription is inactive they show the paywall instead of the
// real screen. Messages and Profil stay ungated so the seller can still
// chat, reach settings, and finish payout onboarding.
const List<NavTab> kSellerNavTabs = [
  NavTab(
    icon: Iconsax.home,
    label: 'Accueil',
    screen: SubscriptionGate(child: SellerHomeScreen()),
  ),
  NavTab(
    icon: Iconsax.shop,
    label: 'Commandes',
    screen: SubscriptionGate(child: OrderRequestsScreen()),
  ),
  NavTab(
    icon: Iconsax.message,
    label: 'Messages',
    screen: ConversationsListScreen(
      filter: ConversationType.buyerSeller,
      title: 'Liste des discussions',
      showBackArrow: false,
    ),
  ),
  // "Mes plats" + a "+" icon so the seller immediately sees where to add
  // dishes (the old "Catalogue" label was ambiguous). The nav bar shows the
  // label only when the tab is selected; the always-visible "+" icon is the
  // micro add affordance the client asked for.
  NavTab(
    icon: Iconsax.add_circle,
    label: 'Mes plats',
    screen: SubscriptionGate(child: SellerProductsScreen()),
  ),
  NavTab(icon: Iconsax.user, label: 'Profil', screen: SettingsScreen()),
];
