class Kitchen {
  const Kitchen({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.chefImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.hasFreeDelivery,
    required this.deliveryTime,
    required this.tags,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String chefImageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool hasFreeDelivery;
  final String deliveryTime;
  final List<String> tags;
}
