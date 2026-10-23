import '../core/clock.dart';
import '../core/flags.dart';
import 'activity_controller.dart';
import 'plan_controller.dart';
import 'profile_controller.dart';
import 'progress_controller.dart';
import 'shell_controller.dart';
import 'toast_controller.dart';

/// Everything the screens need, built once in main.dart (or in tests).
class AppControllers {
  AppControllers({
    required this.shell,
    required this.plan,
    required this.activity,
    required this.progress,
    required this.profile,
    required this.toast,
    required this.clock,
    this.flags = const Flags(),
  });

  final ShellController shell;
  final PlanController plan;
  final ActivityController activity;
  final ProgressController progress;
  final ProfileController profile;
  final ToastController toast;
  final Clock clock;
  final Flags flags;

  /// Starts every initial load. Safe to call without awaiting.
  Future<void> loadAll() async {
    await Future.wait(<Future<void>>[
      profile.load(),
      plan.load(),
      activity.load(),
      progress.load(),
    ]);
  }

  void dispose() {
    shell.dispose();
    plan.dispose();
    activity.dispose();
    progress.dispose();
    profile.dispose();
    toast.dispose();
  }
}
