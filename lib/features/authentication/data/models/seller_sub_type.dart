enum SellerSubType {
  /// "Le Bon Fait Maison" — a private cook from home. Auto-approved on
  /// signup, capped at €4.50/dish, skips business-info collection.
  faitMaison,

  /// "L'Atelier Traiteur" — a registered caterer. Requires SIRET and
  /// manual KYC review.
  traiteur,

  /// "Sauve Ton Panier" — a restaurant selling surplus. Requires SIRET,
  /// facade photo, and opening hours; manual review.
  restaurant,
}
