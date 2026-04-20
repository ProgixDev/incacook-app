class ProductAddOn {
  const ProductAddOn({
    required this.id,
    required this.label,
    required this.priceDelta,
    this.isSelectedByDefault = false,
  });

  final String id;
  final String label;
  final double priceDelta;
  final bool isSelectedByDefault;
}
