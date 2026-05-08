import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/client/domain/food_listing.dart';

class FoodListingCard extends StatelessWidget {
  const FoodListingCard({super.key, required this.listing, this.onTap});

  final FoodListing listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = listing.portionsLeft == 1
        ? '${listing.portionsLeft} ${AppTexts.feedPortionLeft}'
        : '${listing.portionsLeft} ${AppTexts.feedPortionsLeft}';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(listing.imagePath, fit: BoxFit.cover),

              //* gradient for text legibility
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x33000000),
                        Color(0x66000000),
                      ],
                      stops: [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              //* frosted-glass footer
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.12),
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                              ),
                              const Gap(4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          //* price (or "Gratuit" for solidarity listings)
                          listing.price == 0
                              ? Text(
                                  AppTexts.feedPriceFree,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        height: 1,
                                      ),
                                )
                              : PriceDisplay(
                                  price: listing.price,
                                  currencySize: 15,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
