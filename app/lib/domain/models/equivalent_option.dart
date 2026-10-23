import '../errors.dart';
import 'plan.dart';
import 'portions.dart';

/// A dish that can replace a meal of the same slot.
class EquivalentOption {
  EquivalentOption({
    required this.id,
    required this.slot,
    required this.dish,
    required this.portions,
  }) {
    if (id.isEmpty || dish.trim().isEmpty) {
      throw const DomainValidationError('Option id and dish are required');
    }
  }

  final String id;
  final MealSlot slot;
  final String dish;
  final Portions portions;
}
