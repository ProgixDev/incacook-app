import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/home/domain/food_listing.dart';

class CartSellerCard extends StatelessWidget {
  const CartSellerCard({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            listing.imagePath,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const Gap(AppSizes.sm + 2),
        Expanded(
          child: Text(
            listing.sellerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
