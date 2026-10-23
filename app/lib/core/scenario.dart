/// Mock data scenarios, selected with `--dart-define=MOCK_SCENARIO=value`.
enum Scenario {
  normal,
  noPlan,
  error;

  /// Whitelisted parse: unknown or empty values fall back to [normal].
  static Scenario parse(String? raw) {
    for (final Scenario s in Scenario.values) {
      if (s.name == raw) return s;
    }
    return Scenario.normal;
  }

  static Scenario get current =>
      parse(const String.fromEnvironment('MOCK_SCENARIO'));
}
