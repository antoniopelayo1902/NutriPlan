import '../models/measurement.dart';

abstract interface class MeasurementRepository {
  /// All measurements, oldest first.
  Future<List<Measurement>> loadAll();
}
