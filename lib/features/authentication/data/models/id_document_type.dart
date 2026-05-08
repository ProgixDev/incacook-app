enum IdDocumentType {
  carteIdentite('Carte d\'identité', requiresVerso: true),
  passeport('Passeport', requiresVerso: false),
  titreSejour('Titre de séjour', requiresVerso: true);

  const IdDocumentType(this.label, {required this.requiresVerso});

  final String label;
  final bool requiresVerso;
}
