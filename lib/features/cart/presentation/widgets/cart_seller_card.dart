import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/models/food_listing.dart';

class CartSellerCard extends StatelessWidget {
  const CartSellerCard({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final url = listing.imageUrl;
    final isNetwork = url.startsWith('http');
    return Row(
      children: [
        ClipOval(
          child: isNetwork
              ? Image.network(
                  url,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    AppImages.foodTest,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(url, width: 40, height: 40, fit: BoxFit.cover),
        ),
        const Gap(AppSizes.sm + 2),
        Expanded(
          child: Text(
            listing.sellerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
