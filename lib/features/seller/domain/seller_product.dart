class SellerProduct {
  const SellerProduct({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.rating,
    required this.prepMinutes,
    required this.price,
    required this.discountPercent,
    required this.isAvailable,
    required this.isVeg,
  });

  final String id;
  final String name;
  final String imagePath;
  final String category;
  final double rating;
  final int prepMinutes;
  final double price;
  final int discountPercent;
  final bool isAvailable;
  final bool isVeg;

  SellerProduct copyWith({bool? isAvailable}) => SellerProduct(
    id: id,
    name: name,
    imagePath: imagePath,
    category: category,
    rating: rating,
    prepMinutes: prepMinutes,
    price: price,
    discountPercent: discountPercent,
    isAvailable: isAvailable ?? this.isAvailable,
    isVeg: isVeg,
  );
}
