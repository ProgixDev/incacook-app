/// A sub-rating attached to a review (`criterion` is the backend enum string:
/// HYGIENE | FOOD_QUALITY | PACKAGING). Hygiene is binary (0 or 100); the
/// score criteria are 1–5.
class ReviewCriterion {
  const ReviewCriterion({
    required this.criterion,
    required this.value,
    required this.sampleCount,
  });

  final String criterion;
  final double value;
  final int sampleCount;

  factory ReviewCriterion.fromJson(Map<String, dynamic> json) {
    return ReviewCriterion(
      criterion: json['criterion'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      sampleCount: (json['sampleCount'] as num?)?.toInt() ?? 1,
    );
  }
}

/// A buyer's review of an order/seller, from `GET /v1/sellers/:id/reviews`.
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.body,
    required this.createdAt,
    required this.authorName,
    this.authorAvatarPath,
    this.criteria = const <ReviewCriterion>[],
  });

  final String id;

  /// Overall 1–5 stars.
  final int rating;
  final String body;
  final DateTime createdAt;
  final String authorName;

  /// Storage path in `avatars/`; resolve with `ApiConstants.publicImageUrl`.
  final String? authorAvatarPath;
  final List<ReviewCriterion> criteria;

  factory Review.fromJson(Map<String, dynamic> json) {
    final author = (json['author'] as Map<String, dynamic>?) ?? const {};
    final first = author['firstName'] as String? ?? '';
    final last = author['lastName'] as String? ?? '';
    final name = '$first $last'.trim();
    return Review(
      id: json['id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      authorName: name.isEmpty ? 'Client' : name,
      authorAvatarPath: author['avatarPath'] as String?,
      criteria: ((json['criteriaRatings'] as List?) ?? const <dynamic>[])
          .map((e) => ReviewCriterion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
