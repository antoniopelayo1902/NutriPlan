import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../application/account_identity.dart';
import '../application/activity_controller.dart';
import '../application/app_controllers.dart';
import '../application/profile_controller.dart';
import '../application/profile_photo_controller.dart';
import '../application/nutri_controller.dart';
import '../application/toast_controller.dart';
import '../domain/models/user_role.dart';

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
        Provider<UserRole>.value(value: UserRole.patient),
        Provider<AppControllers>.value(value: controllers),
        ListenableProvider<AccountIdentity>.value(value: controllers.profile),
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

/// Lo mismo para la cuenta de nutrióloga, que no usa los controllers del
/// paciente.
class NutriProviders extends StatelessWidget {
  const NutriProviders({
    super.key,
    required this.nutri,
    required this.toast,
    required this.photo,
    required this.child,
  });

  final NutriController nutri;
  final ToastController toast;
  final ProfilePhotoController photo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRole>.value(value: UserRole.nutritionist),
        ChangeNotifierProvider<NutriController>.value(value: nutri),
        ListenableProvider<AccountIdentity>.value(value: nutri),
        ChangeNotifierProvider<ProfilePhotoController>.value(value: photo),
        ChangeNotifierProvider<ToastController>.value(value: toast),
      ],
      child: child,
    );
  }
}
