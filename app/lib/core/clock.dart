/// Injectable time source so tests can fix "now".
typedef Clock = DateTime Function();

/// Date-only (local midnight) version of [d].
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Monday of the week that contains [d] (date-only).
DateTime mondayOf(DateTime d) {
  final DateTime day = dateOnly(d);
  return DateTime(
    day.year,
    day.month,
    day.day - (day.weekday - DateTime.monday),
  );
}

/// True when both dates fall on the same calendar day.
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
