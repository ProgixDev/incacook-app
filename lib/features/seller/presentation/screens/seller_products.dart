import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/listing.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/catalog/data/repositories/listings_repository.dart';
import 'package:incacook/features/catalog/presentation/screens/product_detail.dart';
import 'package:incacook/features/seller/presentation/widgets/add_product_bar.dart';
import 'package:incacook/features/seller/presentation/widgets/add_product_sheet.dart';
import 'package:incacook/features/seller/presentation/widgets/products_tab_toggle.dart';
import 'package:incacook/features/seller/presentation/widgets/seller_product_card.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  List<Listing> _listings = const [];
  ProductsTab _tab = ProductsTab.available;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// `GET /v1/sellers/me/listings` — owner-only feed including unavailable
  /// and expired entries, used by the dashboard's Disponible / Indisponible
  /// tabs.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final items = await ListingsRepository().getMyListings();
      if (!mounted) return;
      setState(() {
        _listings = items;
        _loading = false;
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  /// Optimistic availability toggle — flips locally for instant feedback,
  /// rolls back on backend failure.
  Future<void> _setAvailability(String id, bool available) async {
    final prev = _listings;
    setState(() {
      _listings = [
        for (final l in _listings)
          l.id == id ? l.copyWith(isAvailable: available) : l,
      ];
    });
    try {
      await ListingsRepository().setAvailability(id, isAvailable: available);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _listings = prev);
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _listings = prev);
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
    }
  }

  List<Listing> get _filtered => _listings
      .where((l) => l.isAvailable == (_tab == ProductsTab.available))
      .toList();

  /// Adapter for the existing [SellerProductCard], which still consumes the
  /// mock-era [FoodListing] shape. The card now renders network images when
  /// `imageUrl` looks like a URL; we resolve the listing's first storage
  /// path via [ApiConstants.publicImageUrl] and only fall back to the asset
  /// placeholder when the listing has no images.
  FoodListing _toFoodListing(Listing l) => FoodListing(
    id: l.id,
    name: l.name,
    imageUrl: l.imageUrls.isNotEmpty
        ? (ApiConstants.publicImageUrl(l.imageUrls.first) ?? AppImages.foodTest)
        : AppImages.foodTest,
    sellerName: l.sellerName ?? '',
    category: l.category,
    price: l.priceCents / 100,
    portionsLeft: l.portionsLeft ?? 0,
    fulfillment: l.fulfillment,
    // FoodListing requires a non-null expiresAt; restaurant/traiteur
    // permanent items get a far-future placeholder.
    expiresAt: l.expiresAt ?? DateTime.now().add(const Duration(days: 365)),
    originalPrice: l.originalPriceCents == null
        ? null
        : l.originalPriceCents! / 100,
    discountPercent: l.discountPercent ?? 0,
    prepMinutes: l.prepMinutes,
    isAvailable: l.isAvailable,
    isVeg: l.isVeg,
    menuCategory: l.menuCategory,
    dietaryTags: l.dietaryTags,
    allergens: l.allergens,
    otherAllergens: l.otherAllergens,
  );

  Future<void> _openDetail(Listing l) async {
    final changed = await Get.to<bool>(
      () => ProductDetailScreen(listing: l, isSeller: true),
    );
    if (changed == true) await _load();
  }

  Future<void> _openAdd() async {
    final created = await AddProductSheet.show(context);
    if (created == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      body: Stack(
        children: [
          //* decorative top-right blob (purely cosmetic, no input).
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                children: [
                  const Gap(AppSizes.md),
                  AddProductBar(onTap: _openAdd),
                  const Gap(AppSizes.md),
                  ProductsTabToggle(
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                  const Gap(AppSizes.md),
                  Expanded(child: _buildBody(filtered)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<Listing> filtered) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _LoadErrorView(message: _loadError!, onRetry: _load);
    }
    if (filtered.isEmpty) {
      return const _EmptyProducts();
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceBtwSections),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const Gap(AppSizes.md),
        itemBuilder: (context, i) {
          final l = filtered[i];
          return SellerProductCard(
            product: _toFoodListing(l),
            onAvailabilityChanged: (v) => _setAvailability(l.id, v),
            onTap: () => _openDetail(l),
          );
        },
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            AppAnimations.empty,
            width: MediaQuery.of(context).size.width * 0.6,
            fit: BoxFit.contain,
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.sellerProductsEmptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when `GET /v1/sellers/me/listings` fails — surfaces the backend
/// message and lets the seller retry without leaving the tab.
class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: scheme.onSurfaceVariant),
            const Gap(AppSizes.md),
            Text(
              AppTexts.sellerProductsLoadError,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Gap(AppSizes.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}