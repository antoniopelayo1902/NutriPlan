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
import 'core/scenario.dart';
import 'data/firestore/firestore_activity_repository.dart';
import 'data/firestore/firestore_measurement_repository.dart';
import 'data/firestore/firestore_patient_repository.dart';
import 'data/firestore/firestore_plan_repository.dart';
import 'data/in_memory_activity_repository.dart';
import 'data/in_memory_measurement_repository.dart';
import 'data/in_memory_patient_repository.dart';
import 'data/in_memory_plan_repository.dart';
import 'data/mock/seed.dart';
import 'data/profile_photo_store.dart';

/// Wires the in-memory mock data to the controllers. Used by main.dart and
/// by tests (with a fixed clock and zero latency).
AppControllers buildAppControllers({
  Clock? clock,
  Scenario scenario = Scenario.normal,
  Duration latency = Duration.zero,
  Flags flags = const Flags(),
  Duration toastDuration = const Duration(milliseconds: 2500),
}) {
  final Clock now = clock ?? DateTime.now;
  final SeedData seed = SeedData.build(now);
  final InMemoryPlanRepository planRepo = InMemoryPlanRepository(
    plan: seed.plan,
    options: seed.options,
    clock: now,
    scenario: scenario,
    latency: latency,
  );
  return AppControllers(
    shell: ShellController(),
    plan: PlanController(repository: planRepo, clock: now),
    activity: ActivityController(
      repository: InMemoryActivityRepository(
        goal: seed.goal,
        logs: seed.logs,
        ownerPatientId: SeedData.patientId,
        clock: now,
        scenario: scenario,
        latency: latency,
      ),
      clock: now,
      patientId: SeedData.patientId,
    ),
    progress: ProgressController(
      InMemoryMeasurementRepository(
        measurements: seed.measurements,
        scenario: scenario,
        latency: latency,
      ),
    ),
    profile: ProfileController(
      InMemoryPatientRepository(
        patient: seed.patient,
        nutritionist: seed.nutritionist,
        latency: latency,
      ),
    ),
    toast: ToastController(duration: toastDuration),
    clock: now,
    flags: flags,
  );
}

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
