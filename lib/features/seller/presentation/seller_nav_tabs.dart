import 'package:incacook/core/common/widgets/navigation/nav_tab.dart';
import 'package:incacook/features/seller/presentation/screens/order_requests.dart';
import 'package:incacook/features/seller/presentation/screens/seller_home.dart';
import 'package:incacook/features/seller/presentation/screens/seller_products.dart';
import 'package:incacook/features/settings/presentation/screens/settings.dart';
import 'package:iconsax/iconsax.dart';

const List<NavTab> kSellerNavTabs = [
  NavTab(icon: Iconsax.home, label: 'Accueil', screen: SellerHomeScreen()),
  NavTab(icon: Iconsax.shop, label: 'Commandes', screen: OrderRequestsScreen()),
  NavTab(
    icon: Iconsax.category,
    label: 'Catalogue',
    screen: SellerProductsScreen(),
  ),
  NavTab(icon: Iconsax.user, label: 'Profil', screen: SettingsScreen()),
];
