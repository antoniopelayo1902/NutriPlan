import 'package:flutter/foundation.dart';

import '../domain/models/measurement.dart';
import '../domain/repositories/measurement_repository.dart';
import '../domain/services/measurement_trend.dart';

class ProgressController extends ChangeNotifier {
  ProgressController(this._repository);

  final MeasurementRepository _repository;

  bool _loading = true;
  Object? _error;
  List<Measurement> _measurements = <Measurement>[];

  bool get loading => _loading;
  Object? get error => _error;
  bool get hasError => _error != null;
  List<Measurement> get measurements =>
      List<Measurement>.unmodifiable(_measurements);
  Measurement? get latest => _measurements.isEmpty ? null : _measurements.last;
  Measurement? get first => _measurements.isEmpty ? null : _measurements.first;

  MetricTrend? trend(MeasurementMetric metric) =>
      trendFor(_measurements, metric);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _measurements = await _repository.loadAll();
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();
}
