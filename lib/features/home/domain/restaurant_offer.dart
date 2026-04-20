class RestaurantOffer {
  const RestaurantOffer({
    required this.name,
    required this.imagePath,
    required this.offerLabel,
    required this.rating,
    required this.distanceKm,
  });

  final String name;
  final String imagePath;
  final String offerLabel;
  final double rating;
  final double distanceKm;
}
