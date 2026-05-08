enum Allergen {
  gluten('Gluten'),
  crustaces('Crustacés'),
  oeufs('Œufs'),
  poissons('Poissons'),
  arachides('Arachides'),
  soja('Soja'),
  lait('Lait'),
  fruitsACoque('Fruits à coque'),
  celeri('Céleri'),
  moutarde('Moutarde'),
  sesame('Sésame'),
  sulfites('Sulfites'),
  lupin('Lupin'),
  mollusques('Mollusques');

  const Allergen(this.label);

  final String label;
}
