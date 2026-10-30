import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutriplan/core/i18n/strings_es_mx.dart';
import 'package:nutriplan/main.dart' as app;

/// Runs the real app on a device against the Firebase project: create an
/// account, sign out, reject a wrong password and sign back in.
Future<void> waitFor(WidgetTester tester, Finder finder, {int seconds = 20}) async {
  for (int i = 0; i < seconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Not found: $finder');
}

Future<void> waitForUser(WidgetTester tester, {required bool signedIn}) async {
  for (int i = 0; i < 80; i++) {
    if ((FirebaseAuth.instance.currentUser != null) == signedIn) break;
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> typeKey(WidgetTester tester, String key, String text) async {
  final Finder finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
  await tester.pump();
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final Finder finder = find.byKey(Key(key));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create account, sign out, wrong password, sign in', (tester) async {
    await app.main();
    // Start from the login screen even if a previous run left a session.
    await FirebaseAuth.instance.signOut();
    await waitFor(tester, find.byKey(const Key('emailField')));

    final String email = 'prueba${DateTime.now().millisecondsSinceEpoch}@nutriplan.test';
    const String password = 'Prueba123';

    // 1. Create account -> the app shell appears.
    await typeKey(tester, 'emailField', email);
    await typeKey(tester, 'passwordField', password);
    await tapKey(tester, 'registerButton');
    await waitForUser(tester, signedIn: true);
    expect(FirebaseAuth.instance.currentUser?.email, email);
    await waitFor(tester, find.text(S.tabProgreso));

    // 2. Sign out from the Progreso tab.
    await tester.tap(find.text(S.tabProgreso));
    await tester.pumpAndSettle();
    await waitFor(tester, find.byKey(const Key('signOutButton')));
    await tapKey(tester, 'signOutButton');
    await waitForUser(tester, signedIn: false);
    expect(FirebaseAuth.instance.currentUser, isNull);
    await waitFor(tester, find.byKey(const Key('emailField')));

    // 3. Wrong password is rejected with the Spanish message.
    await typeKey(tester, 'emailField', email);
    await typeKey(tester, 'passwordField', 'mala1234');
    await tapKey(tester, 'loginButton');
    await waitFor(tester, find.text(S.authWrongCredentials));
    expect(FirebaseAuth.instance.currentUser, isNull);

    // 4. Correct password signs in.
    await typeKey(tester, 'passwordField', password);
    await tapKey(tester, 'loginButton');
    await waitForUser(tester, signedIn: true);
    expect(FirebaseAuth.instance.currentUser?.email, email);
    await waitFor(tester, find.text(S.tabProgreso));

    await FirebaseAuth.instance.signOut();
  });
}
