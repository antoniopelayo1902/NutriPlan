/// SMAE food groups with their energy per equivalent portion.
enum FoodGroup {
  verdura(25),
  fruta(60),
  cereal(70),
  aoa(55),
  leguminosa(120),
  leche(95),
  grasa(45),
  azucar(40);

  const FoodGroup(this.kcalPerPortion);

  final int kcalPerPortion;

  /// Groups shown in the daily budget (sugar is excluded).
  static const List<FoodGroup> budgeted = <FoodGroup>[
    verdura,
    fruta,
    cereal,
    aoa,
    leguminosa,
    leche,
    grasa,
  ];
}
