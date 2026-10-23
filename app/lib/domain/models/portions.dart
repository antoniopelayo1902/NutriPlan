import '../errors.dart';
import 'food_group.dart';

/// Immutable amount of equivalent portions per food group.
/// Every value is >= 0 and a multiple of 0.5.
class Portions {
  Portions([Map<FoodGroup, double> amounts = const <FoodGroup, double>{}])
    : _amounts = _validated(amounts);

  const Portions._(this._amounts);

  /// Upper bound per group (sanity limit).
  static const double maxPerGroup = 20;

  static const Portions zero = Portions._(<FoodGroup, double>{});

  final Map<FoodGroup, double> _amounts;

  static Map<FoodGroup, double> _validated(Map<FoodGroup, double> input) {
    final Map<FoodGroup, double> out = <FoodGroup, double>{};
    for (final MapEntry<FoodGroup, double> e in input.entries) {
      final double v = e.value;
      if (v.isNaN ||
          v.isInfinite ||
          v.isNegative ||
          v > maxPerGroup ||
          (v * 2) != (v * 2).roundToDouble()) {
        throw const DomainValidationError(
          'Portions must be multiples of 0.5 between 0 and 20',
        );
      }
      if (v > 0) out[e.key] = v;
    }
    return Map<FoodGroup, double>.unmodifiable(out);
  }

  double operator [](FoodGroup g) => _amounts[g] ?? 0;

  Portions operator +(Portions other) {
    final Map<FoodGroup, double> out = <FoodGroup, double>{};
    for (final FoodGroup g in FoodGroup.values) {
      out[g] = this[g] + other[g];
    }
    return Portions(out);
  }

  /// Throws [DomainValidationError] if any group would go negative.
  Portions operator -(Portions other) {
    final Map<FoodGroup, double> out = <FoodGroup, double>{};
    for (final FoodGroup g in FoodGroup.values) {
      out[g] = this[g] - other[g];
    }
    return Portions(out);
  }

  Portions withGroup(FoodGroup g, double amount) {
    return Portions(<FoodGroup, double>{..._amounts, g: amount});
  }

  /// Groups with a positive amount, in enum order.
  List<MapEntry<FoodGroup, double>> get entries =>
      <MapEntry<FoodGroup, double>>[
        for (final FoodGroup g in FoodGroup.values)
          if (this[g] > 0) MapEntry<FoodGroup, double>(g, this[g]),
      ];

  bool get isEmpty => _amounts.isEmpty;

  double get totalPortions =>
      _amounts.values.fold(0, (double a, double b) => a + b);

  double get kcal => FoodGroup.values.fold(
    0,
    (double sum, FoodGroup g) => sum + this[g] * g.kcalPerPortion,
  );

  @override
  bool operator ==(Object other) {
    if (other is! Portions) return false;
    for (final FoodGroup g in FoodGroup.values) {
      if (this[g] != other[g]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
    for (final FoodGroup g in FoodGroup.values) this[g],
  ]);
}
