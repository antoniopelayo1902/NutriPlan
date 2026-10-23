import '../models/equivalent_option.dart';
import '../models/plan.dart';

abstract interface class PlanRepository {
  /// The published plan, or null when the nutritionist has not published one.
  Future<Plan?> loadPlan();

  /// Persists one day. Throws NotFoundError for an unknown day or meal id.
  Future<void> saveDay(DayPlan day);

  /// Equivalents the patient can pick for a slot.
  Future<List<EquivalentOption>> loadOptions(MealSlot slot);
}
