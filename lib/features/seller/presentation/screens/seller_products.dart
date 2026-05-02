import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:homemade/core/constants/animations.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/decor/decor_blob.dart';
import 'package:homemade/features/catalog/presentation/screens/product_detail.dart';
import 'package:homemade/features/seller/data/seller_product_mock_data.dart';
import 'package:homemade/features/seller/domain/seller_product.dart';
import 'package:homemade/features/seller/presentation/widgets/add_product_bar.dart';
import 'package:homemade/features/seller/presentation/widgets/add_product_sheet.dart';
import 'package:homemade/features/seller/presentation/widgets/products_tab_toggle.dart';
import 'package:homemade/features/seller/presentation/widgets/seller_product_card.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  late List<SellerProduct> _products;
  ProductsTab _tab = ProductsTab.available;

  @override
  void initState() {
    super.initState();
    _products = SellerProductMockData.demoProducts();
  }

  void _setAvailability(String id, bool available) {
    setState(() {
      _products = [
        for (final p in _products)
          p.id == id ? p.copyWith(isAvailable: available) : p,
      ];
    });
  }

  List<SellerProduct> get _filtered => _products
      .where((p) => p.isAvailable == (_tab == ProductsTab.available))
      .toList();

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
                  AddProductBar(
                    onTap: () => AddProductSheet.show(context),
                  ),
                  const Gap(AppSizes.md),
                  ProductsTabToggle(
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                  const Gap(AppSizes.md),
                  Expanded(
                    child: filtered.isEmpty
                        ? const _EmptyProducts()
                        : ListView.separated(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.spaceBtwSections,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Gap(AppSizes.md),
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              return SellerProductCard(
                                product: p,
                                onAvailabilityChanged: (v) =>
                                    _setAvailability(p.id, v),
                                onTap: () =>
                                    Get.to(() => const ProductDetailScreen()),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
