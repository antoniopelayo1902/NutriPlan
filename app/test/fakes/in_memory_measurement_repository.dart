import 'scenario.dart';

import 'package:nutriplan/domain/errors.dart';
import 'package:nutriplan/domain/models/measurement.dart';
import 'package:nutriplan/domain/repositories/measurement_repository.dart';

class InMemoryMeasurementRepository implements MeasurementRepository {
  InMemoryMeasurementRepository({
    required List<Measurement> measurements,
    this.scenario = Scenario.normal,
    this.latency = Duration.zero,
  }) : _items = List<Measurement>.of(measurements);

  final List<Measurement> _items;
  final Scenario scenario;
  final Duration latency;
  bool _failedOnce = false;

  @override
  Future<List<Measurement>> loadAll() async {
    await Future<void>.delayed(latency);
    if (scenario == Scenario.error && !_failedOnce) {
      _failedOnce = true;
      throw const RepositoryError('measurements unavailable');
    }
    final List<Measurement> out = List<Measurement>.of(_items)
      ..sort((Measurement a, Measurement b) => a.date.compareTo(b.date));
    return out;
  }
}
