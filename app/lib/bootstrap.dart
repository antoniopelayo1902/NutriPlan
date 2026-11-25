import 'application/activity_controller.dart';
import 'application/app_controllers.dart';
import 'application/plan_controller.dart';
import 'application/profile_controller.dart';
import 'application/profile_photo_controller.dart';
import 'application/progress_controller.dart';
import 'application/shell_controller.dart';
import 'application/toast_controller.dart';
import 'core/clock.dart';
import 'core/flags.dart';
import 'data/firestore/firestore_activity_repository.dart';
import 'data/firestore/firestore_measurement_repository.dart';
import 'data/firestore/firestore_patient_repository.dart';
import 'data/firestore/firestore_plan_repository.dart';
import 'data/profile_photo_store.dart';

/// Conecta los controllers con Firestore para el usuario [uid] que inició
/// sesión. Toda la información de las pantallas sale de aquí.
AppControllers buildFirestoreControllers({
  required String uid,
  Clock clock = DateTime.now,
  Flags flags = const Flags(),
}) {
  return AppControllers(
    shell: ShellController(),
    plan: PlanController(
      repository: FirestorePlanRepository(uid: uid, clock: clock),
      clock: clock,
    ),
    activity: ActivityController(
      repository: FirestoreActivityRepository(uid: uid, clock: clock),
      clock: clock,
      patientId: uid,
    ),
    progress: ProgressController(FirestoreMeasurementRepository(uid: uid)),
    profile: ProfileController(FirestorePatientRepository(uid: uid)),
    toast: ToastController(),
    photo: ProfilePhotoController(
      load: () => ProfilePhotoStore.load(uid),
      save: (String path) => ProfilePhotoStore.save(uid, path),
    ),
    clock: clock,
    flags: flags,
  );
}
