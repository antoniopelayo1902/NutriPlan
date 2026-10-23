import '../../domain/models/food_group.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/portions.dart';
import '../../domain/services/measurement_trend.dart';
import '../i18n/strings_es_mx.dart';

/// es-MX formatting per the product spec: decimal comma, thousands comma,
/// U+2212 minus sign, prime for minutes. Pure Dart, no Flutter imports.
const String minusSign = '−';
const String prime = '′';

String _group(String digits) {
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final int remaining = digits.length - i;
    out.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) out.write(',');
  }
  return out.toString();
}

/// "1,820" for 1820. Negative numbers use U+2212.
String formatInt(int value) {
  final String body = _group(value.abs().toString());
  return value < 0 ? '$minusSign$body' : body;
}

/// "71,2" for 71.2 with [digits] decimals. Negative uses U+2212.
String formatDecimal(double value, {int digits = 1}) {
  final String fixed = value.abs().toStringAsFixed(digits);
  final List<String> parts = fixed.split('.');
  final String whole = _group(parts.first);
  final String body = parts.length > 1 ? '$whole,${parts[1]}' : whole;
  final bool isZero = double.parse(fixed) == 0;
  return (value < 0 && !isZero) ? '$minusSign$body' : body;
}

/// Delta with explicit sign: "+1,2", "−1,8", "0".
String formatSigned(double value, {int digits = 1}) {
  final String body = formatDecimal(value, digits: digits);
  final bool isZero = double.parse(value.abs().toStringAsFixed(digits)) == 0;
  if (isZero) return formatDecimal(0, digits: digits);
  return value > 0 ? '+$body' : body;
}

String formatSignedInt(int value) {
  if (value == 0) return '0';
  return value > 0 ? '+${formatInt(value)}' : formatInt(value);
}

/// "71,2 kg", "1,820 kcal".
String formatWithUnit(String number, String unit) => '$number $unit';

/// "30′".
String formatMinutes(int minutes) => '${formatInt(minutes)}$prime';

/// 0 -> "0", 0.5 -> "½", 1 -> "1", 1.5 -> "1½", 2 -> "2".
String formatPortion(double amount) {
  final int whole = amount.floor();
  final bool half = (amount - whole) >= 0.5;
  if (whole == 0 && half) return '½';
  return half ? '$whole½' : '$whole';
}

/// "8:00" for "08:00".
String formatTime(String hhmm) {
  final List<String> parts = hhmm.split(':');
  if (parts.length != 2) return hhmm;
  return '${int.parse(parts[0])}:${parts[1]}';
}

String monthName(int month) => S.months[month - 1];

String weekdayName(int weekday) => S.weekdays[weekday - 1];

/// "12 de septiembre".
String formatDayMonth(DateTime d) => '${d.day} de ${monthName(d.month)}';

/// "miércoles 8 de octubre".
String formatLongDate(DateTime d) =>
    '${weekdayName(d.weekday)} ${formatDayMonth(d)}';

/// "Plural" label of a group when [amount] > 1, singular otherwise.
String groupTagLabel(FoodGroup g, double amount) {
  final List<String> forms = S.groupTags[g.name]!;
  return amount > 1 ? forms[1] : forms[0];
}

/// Display order of groups in portion tags.
const List<FoodGroup> tagOrder = <FoodGroup>[
  FoodGroup.verdura,
  FoodGroup.cereal,
  FoodGroup.fruta,
  FoodGroup.aoa,
  FoodGroup.leguminosa,
  FoodGroup.leche,
  FoodGroup.grasa,
  FoodGroup.azucar,
];

/// "1 Cereal \u00b7 1 Fruta", groups in fixed display order.
String formatPortionTags(Portions portions) {
  return <String>[
    for (final FoodGroup g in tagOrder)
      if (portions[g] > 0)
        '${formatPortion(portions[g])} ${groupTagLabel(g, portions[g])}',
  ].join(' \u00b7 ');
}

String groupBudgetLabel(FoodGroup g) => S.groupBudget[g.name]!;

String metricLabel(MeasurementMetric m) {
  switch (m) {
    case MeasurementMetric.weight:
      return S.metricWeight;
    case MeasurementMetric.bodyFat:
      return S.metricBodyFat;
    case MeasurementMetric.muscle:
      return S.metricMuscle;
    case MeasurementMetric.waist:
      return S.metricWaist;
    case MeasurementMetric.tricipital:
      return S.metricTricipital;
  }
}

String metricUnit(MeasurementMetric m) {
  switch (m) {
    case MeasurementMetric.weight:
    case MeasurementMetric.muscle:
      return S.unitKg;
    case MeasurementMetric.bodyFat:
      return S.unitPct;
    case MeasurementMetric.waist:
      return S.unitCm;
    case MeasurementMetric.tricipital:
      return S.unitMm;
  }
}

/// Three-letter month abbreviation: "jun".
String monthShort(int month) => monthName(month).substring(0, 3);

String slotLabel(MealSlot slot) {
  switch (slot) {
    case MealSlot.desayuno:
      return S.slotDesayuno;
    case MealSlot.colacion:
      return S.slotColacion;
    case MealSlot.comida:
      return S.slotComida;
    case MealSlot.cena:
      return S.slotCena;
  }
}
