import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../application/activity_controller.dart';
import '../application/app_controllers.dart';
import '../application/profile_controller.dart';
import '../application/profile_photo_controller.dart';
import '../application/toast_controller.dart';

/// Pone los controllers arriba del Navigator con Provider, así cualquier
/// pantalla (también las que se abren con push) los puede leer.
class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.controllers,
    required this.child,
  });

  final AppControllers controllers;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppControllers>.value(value: controllers),
        ChangeNotifierProvider<ActivityController>.value(
          value: controllers.activity,
        ),
        ChangeNotifierProvider<ProfileController>.value(
          value: controllers.profile,
        ),
        ChangeNotifierProvider<ProfilePhotoController>.value(
          value: controllers.photo,
        ),
        ChangeNotifierProvider<ToastController>.value(value: controllers.toast),
      ],
      child: child,
    );
  }
}
