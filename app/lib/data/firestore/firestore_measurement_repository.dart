import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/measurement.dart';
import '../../domain/repositories/measurement_repository.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Medidas de las consultas en users/{uid}/measurements.
class FirestoreMeasurementRepository implements MeasurementRepository {
  FirestoreMeasurementRepository({required this.uid});

  final String uid;

  /// Todas las medidas, de la más antigua a la más reciente.
  @override
  Future<List<Measurement>> loadAll() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await FirestorePaths.measurements(uid).orderBy('date').get();
    return <Measurement>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        FirestoreMappers.measurementFromMap(d.id, d.data()),
    ];
  }
}
