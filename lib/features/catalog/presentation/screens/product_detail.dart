import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/features/cart/controllers/cart_controller.dart';
import 'package:incacook/features/cart/presentation/widgets/different_seller_dialog.dart';
import 'package:incacook/features/cart/presentation/widgets/floating_cart_bar.dart';
import 'package:incacook/features/catalog/presentation/widgets/added_to_cart_overlay.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_bottom_bar.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_description_block.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_image_header.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_info_pill_bar.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_reviews_section.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_sheet_blend.dart';
import 'package:incacook/features/catalog/presentation/widgets/product_title_price_row.dart';
import 'package:incacook/features/catalog/presentation/widgets/seller_card.dart';
import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/enums/order_enums.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/listing.dart';
import 'package:incacook/core/models/product_add_on.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/features/catalog/data/repositories/listings_repository.dart';
import 'package:incacook/features/moderation/presentation/report_sheet.dart';
import 'package:incacook/features/reviews/data/review.dart';
import 'package:incacook/features/reviews/data/reviews_repository.dart';
import 'package:incacook/features/orders/presentation/widgets/order_customize_sheet.dart';
import 'package:get/get.dart';
import 'package:incacook/features/seller/presentation/screens/seller_profile.dart';
import 'package:incacook/features/seller/presentation/widgets/add_product_sheet.dart';
import 'package:incacook/core/utils/log.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, this.listing, this.isSeller = false});

  /// When non-null, the real backend [Listing] this detail screen is for.
  /// Drives the seller actions (edit + delete) and binds every visible
  /// name/price/description value. Null renders an unavailable state instead
  /// of falling back to demo content.
  final Listing? listing;

  /// Show the seller action bar (Modifier + Supprimer) instead of the
  /// buyer's add-to-cart / order bar. Caller is responsible for only
  /// passing `true` to a seller looking at their own product.
  final bool isSeller;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  //? how tall the frosted-glass strip is. Title + price sit at its bottom,
  //? the top portion shows the blurred image fading into the sheet.
  static const double _blendHeight = 120;

  //? how much bottom padding the scroll content reserves so the floating
  //? bottom bar never covers anything meaningful.
  static const double _bottomBarClearance = 104;

  final PageController _pageController = PageController();
  bool _isFavorited = false;

  /// Fresh detail fetched via `GET /v1/listings/:id`. The feed/seller-list
  /// rows we receive don't include `extras`, so for the seller view we
  /// always re-fetch to render the complete record. Falls back to
  /// `widget.listing` while the request is in flight (or on failure).
  Listing? _fetched;
  bool _refetching = false;

  /// Real reviews for this listing's seller (`GET /v1/sellers/:id/reviews`),
  /// mapped to the card model. Empty until loaded / when no real listing.
  List<ProductReview> _reviews = const <ProductReview>[];

  @override
  void initState() {
    super.initState();
    // Any time a real listing is passed (seller or buyer), re-fetch the
    // full record via `getById` so the view has `extras` and the freshest
    // price/availability — the list/feed endpoints omit `extras`.
    final l = widget.listing;
    if (l != null) {
      _logSeller();
      _refetch();
      _loadReviews(l.sellerId);
    }
  }

  /// First non-empty (trimmed) of [a]/[b], else null. Used to coalesce seller
  /// fields across the detail re-fetch and the feed row.
  static String? _firstNonEmpty(String? a, String? b) {
    if (a != null && a.trim().isNotEmpty) return a.trim();
    if (b != null && b.trim().isNotEmpty) return b.trim();
    return null;
  }

  /// Up-to-2 uppercase initials from a seller name (e.g. "Chez Karim" → "CK").
  /// Empty when no name — SellerCard then shows a default person icon.
  static String _initialsFrom(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final first = parts[0][0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  /// Debug trace of the resolved seller block (no secrets). Logged on open and
  /// after the detail re-fetch lands so we can confirm real data is bound.
  void _logSeller() {
    final name = _firstNonEmpty(
      _fetched?.sellerName,
      widget.listing?.sellerName,
    );
    final id = _fetched?.sellerId ?? widget.listing?.sellerId;
    final avatar = _firstNonEmpty(
      _fetched?.sellerAvatarUrl,
      widget.listing?.sellerAvatarUrl,
    );
    logWarning('[ProductDetail] sellerId=${id ?? 'none'}');
    logWarning(
      '[ProductDetail] sellerName=${name ?? AppTexts.productSellerFallbackName}',
    );
    logError('[ProductDetail] sellerAvatarUrl present=${avatar != null}');
  }

  /// Fetches the seller's real reviews and maps them to the card model.
  /// Best-effort: on failure the section just renders its empty state.
  Future<void> _loadReviews(String sellerId) async {
    try {
      final reviews = await ReviewsRepository().listForSeller(
        sellerId,
        limit: 20,
      );
      if (!mounted) return;
      setState(() => _reviews = reviews.map(_toProductReview).toList());
    } catch (_) {
      // keep empty
    }
  }

  ProductReview _toProductReview(Review r) => ProductReview(
    author: r.authorName,
    avatarUrl:
        ApiConstants.publicImageUrl(r.authorAvatarPath) ?? AppImages.profilePic,
    rating: r.rating.toDouble(),
    body: r.body,
    time: _formatReviewDate(r.createdAt),
  );

  String _formatReviewDate(DateTime d) {
    final local = d.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    return '$dd/$mm/${local.year}';
  }

  /// Opens the report sheet for [l]; confirms on success. "Non fait maison"
  /// is only offered for FAIT_MAISON listings (sheet + backend enforce it).
  Future<void> _openReport(BuildContext context, Listing l) async {
    final submitted = await ReportSheet.show(
      context,
      listingId: l.id,
      isFaitMaison: l.category == SellerCategory.faitMaison,
    );
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci, votre signalement a été envoyé.')),
      );
    }
  }

  Future<void> _refetch() async {
    final l = widget.listing;
    if (l == null) return;
    setState(() => _refetching = true);
    try {
      final fresh = await ListingsRepository().getById(l.id);
      if (!mounted) return;
      setState(() {
        _fetched = fresh;
        _refetching = false;
      });
      _logSeller();
    } catch (_) {
      // Soft-fail: keep the row we already have. Errors are not blocking
      // because the seller can still see the staler list-version of the
      // listing and edit/delete it.
      if (!mounted) return;
      setState(() => _refetching = false);
    }
  }

  Future<void> _openOrderSheet() async {
    final real = _fetched ?? widget.listing;
    if (real == null) return;

    final orderListing = _listingToFoodListing(real);
    final addOns = [
      for (final ex in real.extras)
        ProductAddOn(
          id: ex.id,
          label: ex.label,
          priceDelta: ex.priceDeltaCents / 100,
        ),
    ];
    final draft = await OrderCustomizeSheet.show(
      context,
      listing: orderListing,
      addOns: addOns,
    );
    if (draft == null || !mounted) return;

    await CartController.instance.tryAdd(
      draft,
      resolveConflict: (currentSellerName) => DifferentSellerDialog.show(
        context,
        currentSellerName: currentSellerName,
      ),
    );
  }

  //? quick-add: no customize sheet, default quantity 1, no add-ons, no note
  Future<void> _quickAddToCart() async {
    final real = _fetched ?? widget.listing;
    if (real == null) return;

    final cartListing = _listingToFoodListing(real);
    // Empty id — CartController assigns it on insert.
    final draft = CartItem(
      id: '',
      listing: cartListing,
      quantity: 1,
      selectedAddOns: const [],
      note: '',
    );

    final added = await CartController.instance.tryAdd(
      draft,
      resolveConflict: (currentSellerName) => DifferentSellerDialog.show(
        context,
        currentSellerName: currentSellerName,
      ),
    );
    if (!added || !mounted) return;

    await AddedToCartOverlay.show(context);
  }

  /// Opens the add-product sheet in edit mode for the current listing.
  /// Pops the detail with `true` on a successful PATCH so the catalogue
  /// can refresh.
  Future<void> _onEdit() async {
    final listing = widget.listing;
    if (listing == null) return;
    final updated = await AddProductSheet.show(
      context,
      sellerCategory: listing.category,
      existing: listing,
    );
    if (updated == true && mounted) Get.back<bool>(result: true);
  }

  /// Asks the seller to confirm, then `DELETE /v1/listings/:id`. On success
  /// pops the detail with `true` so the catalogue refreshes; on failure
  /// shows the error and stays on the screen.
  Future<void> _onDelete() async {
    final listing = widget.listing;
    if (listing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppTexts.sellerProductDeleteConfirmTitle),
        content: const Text(AppTexts.sellerProductDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppTexts.sellerProductDeleteConfirmCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: BrandColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppTexts.sellerProductDeleteConfirmCta),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ListingsRepository().delete(listing.id);
      CustomLoaders.successSnackBar(
        title: 'Produit supprimé',
        message: AppTexts.sellerProductDeletedMessage,
      );
      if (mounted) Get.back<bool>(result: true);
    } on ApiFailure catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.message);
    } catch (e) {
      CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Seller looking at their own product → fully dynamic view (every
    // field comes from the backend, no static demo data).
    if (widget.isSeller && widget.listing != null) {
      return _buildSellerView(_fetched ?? widget.listing!);
    }
    final l = _fetched ?? widget.listing;
    if (l == null) return const _UnavailableProductView();

    // Buyers fall through to the existing buyer detail layout. Every visible
    // field below is bound to the real backend listing.
    final imageHeight = DeviceUtils.getScreenHeight(context) * 0.55;
    // Prefer `_fetched` (full record from `getById`, includes extras) over
    // `widget.listing` (feed row, no extras).
    final boundName = l.name;
    final boundPrice = (l.priceCents / 100).toStringAsFixed(2);
    final boundDescription = (l.description ?? '').trim();
    final boundImages = l.imageUrls.isNotEmpty
        ? l.imageUrls
              .map((p) => ApiConstants.publicImageUrl(p) ?? AppImages.foodTest)
              .toList()
        : const <String>[AppImages.foodTest];
    final boundRating = l.rating ?? 0;
    final boundReviewsCount = l.reviewCount ?? 0;
    // Real seller identity — coalesced across the detail re-fetch (`_fetched`)
    // and the feed row (`widget.listing`); both now carry sellerName + avatar.
    // No mock fallback: a missing name shows "Cuisinier", a missing photo
    // shows initials/a default avatar (handled inside SellerCard).
    final resolvedSellerName = _firstNonEmpty(
      _fetched?.sellerName,
      widget.listing?.sellerName,
    );
    final boundSellerName =
        resolvedSellerName ?? AppTexts.productSellerFallbackName;
    final sellerAvatarUrl = ApiConstants.publicImageUrl(
      _firstNonEmpty(
        _fetched?.sellerAvatarUrl,
        widget.listing?.sellerAvatarUrl,
      ),
    );
    final sellerInitials = _initialsFrom(resolvedSellerName);
    final boundDeliveryLabel = _fulfillmentLabel(l.fulfillment);
    final boundPrepLabel = '${l.prepMinutes} min';
    final boundReviews = _reviews;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showBackArrow: true),
      body: Stack(
        children: [
          //* main scrollable content — image + sheet scroll as one
          Positioned.fill(
            child: SingleChildScrollView(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  //* 1. image slider — painted first, so the blend strip
                  //*    above has something behind it to blur
                  SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: ProductImageHeader(
                      pageController: _pageController,
                      images: boundImages,
                      isFavorited: _isFavorited,
                      onFavoriteTap: () =>
                          setState(() => _isFavorited = !_isFavorited),
                      height: imageHeight,
                      //? keep dots above the frosted-glass overlap
                      indicatorBottomPadding: _blendHeight + AppSizes.sm,
                    ),
                  ),

                  //* 2. sheet — overlaps the image by _blendHeight at its top
                  Padding(
                    padding: EdgeInsets.only(top: imageHeight - _blendHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //? frosted strip hosting the title + price so they
                        //? visually sit inside the blurred area
                        ProductSheetBlend(
                          height: _blendHeight,
                          blurSigma: 6,
                          childPadding: const EdgeInsets.fromLTRB(
                            AppSizes.md,
                            AppSizes.md,
                            AppSizes.md,
                            0,
                          ),
                          child: ProductTitlePriceRow(
                            titleLeading: boundName,
                            titleMid: '',
                            titleTrailing: '',
                            shortDescription: '',
                            price: boundPrice,
                            rating: boundRating,
                            reviewsCount: boundReviewsCount,
                          ),
                        ),

                        //? solid sheet body continues below the blend
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.md,
                            AppSizes.lg,
                            AppSizes.md,
                            _bottomBarClearance,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductInfoPillBar(
                                deliveryLabel: boundDeliveryLabel,
                                prepLabel: boundPrepLabel,
                              ),
                              const Gap(AppSizes.lg),
                              SellerCard(
                                name: boundSellerName,
                                // Real seller photo (storage path → public
                                // URL); null falls back to initials/default.
                                avatarUrl: sellerAvatarUrl,
                                initials: sellerInitials,
                                // Thread the seller's user id through so
                                // the chat button can open a pair-keyed
                                // ChatScreen with the real counterparty.
                                sellerUserId: l.sellerId,
                                rating: boundRating,
                                onCardTap: () {
                                  Get.to(
                                    () => SellerProfileLoader(
                                      sellerId: l.sellerId,
                                    ),
                                  );
                                },
                              ),
                              const Gap(AppSizes.lg),
                              ProductDescriptionBlock(
                                description: boundDescription,
                              ),
                              const Gap(AppSizes.lg),
                              //* Allergens — food-safety: always shown to the
                              //* buyer, with an explicit empty state.
                              _AllergensBlock(
                                allergens: l.allergens,
                                otherAllergens: l.otherAllergens,
                              ),
                              const Gap(AppSizes.lg),
                              ProductReviewsSection(
                                averageRating: boundRating,
                                totalReviews: boundReviewsCount,
                                reviews: boundReviews,
                                onSeeAll: () {},
                              ),
                              // Report a dish (real listings only).
                              const Gap(AppSizes.lg),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => _openReport(context, l),
                                  icon: const Icon(
                                    Icons.flag_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Signaler ce plat'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(AppSizes.lg),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //* Bottom action area — seller's own product gets edit/delete;
          //* every other entry shows the buyer cart + order bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: widget.isSeller && widget.listing != null
                ? _SellerActionBar(onEdit: _onEdit, onDelete: _onDelete)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FloatingCartBar(),
                      ProductBottomBar(
                        onAddToCart: _quickAddToCart,
                        onOrder: _openOrderSheet,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Seller view — every field bound to the real listing, no demo data.
  // ───────────────────────────────────────────────────────────────────

  Widget _buildSellerView(Listing l) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final price = (l.priceCents / 100).toStringAsFixed(2);
    // Same identity resolution as the buyer view: the seller sees their own
    // dish presented the way buyers do. Coalesced across the detail re-fetch
    // and the list row, since either can be the first to carry the seller.
    final resolvedSellerName = _firstNonEmpty(
      _fetched?.sellerName,
      widget.listing?.sellerName,
    );
    final sellerAvatarUrl = ApiConstants.publicImageUrl(
      _firstNonEmpty(_fetched?.sellerAvatarUrl, widget.listing?.sellerAvatarUrl),
    );

    return Scaffold(
      appBar: const CustomAppBar(showBackArrow: true),
      body: Stack(
        children: [
          Column(
            children: [
              // Thin progress bar while `getById` is in flight on top of the
              // already-rendered list-row data.
              if (_refetching) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NetworkImageCarousel(paths: l.imageUrls, height: 280),
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seller identity — the profile photo was absent
                            // from this view entirely; only the buyer branch
                            // rendered it. No contact action: this is the
                            // seller's own dish.
                            SellerCard(
                              name:
                                  resolvedSellerName ??
                                  AppTexts.productSellerFallbackName,
                              avatarUrl: sellerAvatarUrl,
                              initials: _initialsFrom(resolvedSellerName),
                              rating: l.rating ?? 0,
                              showContact: false,
                            ),
                            const Gap(AppSizes.md),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    l.name,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Gap(AppSizes.sm),
                                _AvailabilityBadge(available: l.isAvailable),
                              ],
                            ),
                            const Gap(AppSizes.sm),
                            Text(
                              '$price €',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                            ),
                            if ((l.description ?? '').isNotEmpty) ...[
                              const Gap(AppSizes.lg),
                              _SectionTitle(title: 'Description'),
                              const Gap(AppSizes.xs),
                              Text(l.description!, style: textTheme.bodyMedium),
                            ],
                            const Gap(AppSizes.lg),
                            _SectionTitle(title: 'Infos'),
                            const Gap(AppSizes.sm),
                            _InfoRow(
                              icon: Iconsax.category,
                              label: 'Catégorie',
                              value: l.category.label,
                            ),
                            if (l.portionsLeft != null)
                              _InfoRow(
                                icon: Iconsax.box_1,
                                label: 'Portions restantes',
                                value: l.portionsLeft!.toString(),
                              ),
                            _InfoRow(
                              icon: Iconsax.timer_1,
                              label: 'Préparation',
                              value: '${l.prepMinutes} min',
                            ),
                            _InfoRow(
                              icon: Iconsax.routing_2,
                              label: 'Mode de récupération',
                              value: _fulfillmentLabel(l.fulfillment),
                            ),
                            if (l.expiresAt != null)
                              _InfoRow(
                                icon: Iconsax.clock,
                                label: 'Expire',
                                value: _formatExpiry(l.expiresAt!),
                              ),
                            if ((l.menuCategory ?? '').isNotEmpty)
                              _InfoRow(
                                icon: Iconsax.note_text,
                                label: 'Sous-catégorie',
                                value: l.menuCategory!,
                              ),
                            if (l.cuisineTypes.isNotEmpty) ...[
                              const Gap(AppSizes.lg),
                              _SectionTitle(title: 'Cuisines'),
                              const Gap(AppSizes.sm),
                              _LabelChipsWrap(
                                labels: l.cuisineTypes
                                    .map((c) => c.label)
                                    .toList(),
                              ),
                            ],
                            if (l.dishTypes.isNotEmpty) ...[
                              const Gap(AppSizes.lg),
                              _SectionTitle(title: 'Types de plat'),
                              const Gap(AppSizes.sm),
                              _LabelChipsWrap(
                                labels: l.dishTypes
                                    .map((d) => d.label)
                                    .toList(),
                              ),
                            ],
                            if (l.dietaryTags.isNotEmpty) ...[
                              const Gap(AppSizes.lg),
                              _SectionTitle(title: 'Régime alimentaire'),
                              const Gap(AppSizes.sm),
                              _LabelChipsWrap(
                                labels: l.dietaryTags
                                    .map((d) => d.label)
                                    .toList(),
                              ),
                            ],
                            const Gap(AppSizes.lg),
                            _AllergensBlock(
                              allergens: l.allergens,
                              otherAllergens: l.otherAllergens,
                            ),
                            if (l.extras.isNotEmpty) ...[
                              const Gap(AppSizes.lg),
                              _SectionTitle(title: 'Suppléments'),
                              const Gap(AppSizes.sm),
                              for (final ex in l.extras)
                                _ExtraRow(
                                  label: ex.label,
                                  priceDeltaCents: ex.priceDeltaCents,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SellerActionBar(onEdit: _onEdit, onDelete: _onDelete),
          ),
        ],
      ),
    );
  }

  static String _fulfillmentLabel(Fulfillment f) {
    switch (f) {
      case Fulfillment.pickup:
        return 'Sur place';
      case Fulfillment.delivery:
        return 'Livraison';
      case Fulfillment.both:
        return 'Sur place + Livraison';
    }
  }

  /// Compact "DD/MM HH:MM" — enough to recognize today vs. tomorrow at a
  /// glance without dragging in a date-format dependency.
  static String _formatExpiry(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
  }

  /// Adapter so the real backend [Listing] flows through the cart system,
  /// which still talks in the mock-era [FoodListing] shape.
  FoodListing _listingToFoodListing(Listing l) => FoodListing(
    id: l.id,
    name: l.name,
    imageUrl: l.imageUrls.isNotEmpty
        ? (ApiConstants.publicImageUrl(l.imageUrls.first) ?? AppImages.foodTest)
        : AppImages.foodTest,
    // Never '' — a blank name lets the category label stand in for the vendor
    // in the order summary (ISSUE-13); fall back to a generic cook name.
    sellerName: (l.sellerName == null || l.sellerName!.trim().isEmpty)
        ? AppTexts.productSellerFallbackName
        : l.sellerName!,
    category: l.category,
    price: l.priceCents / 100,
    portionsLeft: l.portionsLeft ?? 0,
    fulfillment: l.fulfillment,
    expiresAt: l.expiresAt ?? DateTime.now().add(const Duration(days: 365)),
    distanceKm: l.distanceKm ?? 0,
    rating: l.rating ?? 0,
    reviewCount: l.reviewCount ?? 0,
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
}

/// Replaces the buyer's cart/order bar for sellers viewing their own
/// product. Two actions side-by-side: filled "Modifier" (primary, opens
/// the edit sheet) and outlined-red "Supprimer" (confirms then DELETEs).
class _SellerActionBar extends StatelessWidget {
  const _SellerActionBar({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BrandColors.error,
                    side: const BorderSide(color: BrandColors.error),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(AppTexts.sellerProductDeleteCta),
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(AppTexts.sellerProductEditCta),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableProductView extends StatelessWidget {
  const _UnavailableProductView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackArrow: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.box_remove,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const Gap(AppSizes.md),
              Text(
                'Plat indisponible',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Gap(AppSizes.xs),
              Text(
                'Ce plat ne peut pas être affiché pour le moment.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Seller-view helper widgets — small, dynamic, no static demo content.
// ─────────────────────────────────────────────────────────────────────

/// Horizontal image carousel for a listing's `imageUrls`. Each path is
/// resolved via [ApiConstants.publicImageUrl] and rendered with
/// `Image.network` + an errorBuilder fallback (no asset placeholder so
/// missing-image cases stay obvious instead of looking like a real photo).
class _NetworkImageCarousel extends StatelessWidget {
  const _NetworkImageCarousel({required this.paths, this.height = 280});

  final List<String> paths;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      return _ImagePlaceholder(height: height);
    }
    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: paths.length,
        itemBuilder: (_, i) {
          final url = ApiConstants.publicImageUrl(paths[i]);
          if (url == null) return _ImagePlaceholder(height: height);
          return Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _ImagePlaceholder(height: height),
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Iconsax.gallery_slash,
        size: 48,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = available ? BrandColors.success : BrandColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        available
            ? AppTexts.sellerProductsAvailableLabel
            : AppTexts.sellerProductsNotAvailableLabel,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

/// "Allergènes" section, shared by the buyer + seller detail views. Always
/// rendered (food-safety): chips for the declared allergens, the "Autres"
/// free text if present, or an explicit "Aucun allergène déclaré" when none.
class _AllergensBlock extends StatelessWidget {
  const _AllergensBlock({required this.allergens, this.otherAllergens});

  final List<Allergen> allergens;
  final String? otherAllergens;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasOther = (otherAllergens ?? '').trim().isNotEmpty;
    final hasAny = allergens.isNotEmpty || hasOther;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Allergènes'),
        const Gap(AppSizes.sm),
        if (!hasAny)
          Text(
            'Aucun allergène déclaré',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          )
        else ...[
          if (allergens.isNotEmpty)
            _LabelChipsWrap(labels: allergens.map((a) => a.label).toList()),
          if (hasOther) ...[
            const Gap(AppSizes.sm),
            Text(
              otherAllergens!.trim(),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
        // Food-safety acknowledgment shown to the buyer before ordering.
        const Gap(AppSizes.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
            const Gap(AppSizes.xs),
            Expanded(
              child: Text(
                AppTexts.allergenCheckNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _LabelChipsWrap extends StatelessWidget {
  const _LabelChipsWrap({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final l in labels)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _ExtraRow extends StatelessWidget {
  const _ExtraRow({required this.label, required this.priceDeltaCents});

  final String label;
  final int priceDeltaCents;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final delta = priceDeltaCents / 100;
    final sign = delta > 0 ? '+' : (delta < 0 ? '-' : '');
    final priceText = delta == 0
        ? 'Gratuit'
        : '$sign${delta.abs().toStringAsFixed(2)} €';
    final priceColor = delta > 0
        ? scheme.primary
        : (delta < 0 ? BrandColors.success : scheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(
            priceText,
            style: textTheme.bodyMedium?.copyWith(
              color: priceColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
