import 'package:json_annotation/json_annotation.dart';

enum IdDocumentType {
  @JsonValue('CARTE_IDENTITE')
  carteIdentite('Carte d\'identité', requiresVerso: true),
  @JsonValue('PASSEPORT')
  passeport('Passeport', requiresVerso: false),
  @JsonValue('TITRE_SEJOUR')
  titreSejour('Titre de séjour', requiresVerso: true);

  const IdDocumentType(this.label, {required this.requiresVerso});

  final String label;
  final bool requiresVerso;
}
