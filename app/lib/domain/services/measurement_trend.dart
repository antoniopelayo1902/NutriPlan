import '../models/measurement.dart';

enum MeasurementMetric {
  weight(improvesWhenDown: true),
  bodyFat(improvesWhenDown: true),
  muscle(improvesWhenDown: false),
  waist(improvesWhenDown: true),
  tricipital(improvesWhenDown: true);

  const MeasurementMetric({required this.improvesWhenDown});

  final bool improvesWhenDown;

  double? valueIn(Measurement m) {
    switch (this) {
      case MeasurementMetric.weight:
        return m.weightKg;
      case MeasurementMetric.bodyFat:
        return m.bodyFatPct;
      case MeasurementMetric.muscle:
        return m.muscleKg;
      case MeasurementMetric.waist:
        return m.circumferences.cintura;
      case MeasurementMetric.tricipital:
        return m.skinfolds.tricipital;
    }
  }
}

class MetricTrend {
  const MetricTrend({
    required this.metric,
    required this.dates,
    required this.values,
  });

  final MeasurementMetric metric;
  final List<DateTime> dates;
  final List<double> values;

  double get first => values.first;
  double get latest => values.last;

  /// Latest minus first month.
  double get delta => latest - first;

  bool get improving => metric.improvesWhenDown ? delta < 0 : delta > 0;
}

/// Trend of [metric] across [all], oldest to newest. Null when there is no
/// value for the metric.
MetricTrend? trendFor(List<Measurement> all, MeasurementMetric metric) {
  final List<Measurement> sorted = List<Measurement>.of(all)
    ..sort((Measurement a, Measurement b) => a.date.compareTo(b.date));
  final List<DateTime> dates = <DateTime>[];
  final List<double> values = <double>[];
  for (final Measurement m in sorted) {
    final double? v = metric.valueIn(m);
    if (v != null) {
      dates.add(m.date);
      values.add(v);
    }
  }
  if (values.isEmpty) return null;
  return MetricTrend(metric: metric, dates: dates, values: values);
}
