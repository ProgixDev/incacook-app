import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';

//? category-to-color mapping local to the map feature — not part of AppColors
//? since these are semantic map markers, not app-wide tokens
Color pinColorFor(SellerCategory category) {
  switch (category) {
    case SellerCategory.social:
      return const Color(0xFFE8823B);
    case SellerCategory.traiteur:
      return const Color(0xFF2E7D32);
    case SellerCategory.restaurant:
      return AppColors.primary;
  }
}

String pinEmojiFor(SellerCategory category) {
  switch (category) {
    case SellerCategory.social:
      return '🏠';
    case SellerCategory.traiteur:
      return '🍲';
    case SellerCategory.restaurant:
      return '🏪';
  }
}

class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.listing,
    required this.isSelected,
    required this.isUrgent,
    this.onTap,
  });

  final FoodListing listing;
  final bool isSelected;
  final bool isUrgent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = pinColorFor(listing.category);
    final emoji = pinEmojiFor(listing.category);
    final scale = isSelected ? 1.12 : 1.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isUrgent) const _UrgentHalo(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.white,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 13)),
                      const Gap(4),
                      Text(
                        '€${listing.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                //* tail
                CustomPaint(
                  size: const Size(10, 6),
                  painter: _PinTailPainter(color: color),
                ),
              ],
            ),
            if (isUrgent)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _UrgentHalo extends StatefulWidget {
  const _UrgentHalo();

  @override
  State<_UrgentHalo> createState() => _UrgentHaloState();
}

class _UrgentHaloState extends State<_UrgentHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: 44 + (t * 28),
          height: 44 + (t * 28),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.35 * (1 - t)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
