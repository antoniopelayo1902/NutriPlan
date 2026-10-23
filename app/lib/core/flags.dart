/// Feature flags for the open product decisions (docs: IDEA section 9).
class Flags {
  const Flags({
    this.swapApproval = false,
    this.patientWeightLog = false,
    this.motivational = true,
  });

  /// When on, the "no cabe" toast adds a sentence about the approval request.
  final bool swapApproval;

  /// Whether the patient may log their own weight (no UI yet).
  final bool patientWeightLog;

  /// Streaks and achievement badges.
  final bool motivational;
}
