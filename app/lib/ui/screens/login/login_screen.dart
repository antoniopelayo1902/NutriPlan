import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/auth_service.dart';
import '../../../domain/models/user_role.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/screen_header.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../../web/nutri_web_shell.dart' show kWebWideBreakpoint;
import 'login_field_decoration.dart';
import 'login_web_layout.dart';

/// Email/password and Google sign in, account creation and password reset.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  // The browser version is only for nutritionists.
  UserRole _role = kIsWeb ? UserRole.nutritionist : UserRole.patient;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _fieldsFilled() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() {
        _error = S.loginMissingFields;
        _info = null;
      });
      return false;
    }
    return true;
  }

  /// Runs one Firebase call with the loading state and the error message.
  /// On success AuthGate swaps this screen for the app.
  Future<void> _run(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    // El rol solo se usa si Firebase crea una cuenta nueva.
    AuthService.pendingRole = _role;
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _signIn() {
    if (!_fieldsFilled()) return;
    _run(() => AuthService.signIn(_email.text.trim(), _password.text));
  }

  void _register() {
    if (!_fieldsFilled()) return;
    _run(() => AuthService.register(_email.text.trim(), _password.text));
  }

  void _google() {
    _run(AuthService.signInWithGoogle);
  }

  void _resetPassword() {
    final String email = _email.text.trim();
    if (email.isEmpty) {
      setState(() {
        _error = S.loginMissingEmail;
        _info = null;
      });
      return;
    }
    _run(() async {
      await AuthService.sendPasswordReset(email);
      if (mounted) setState(() => _info = S.loginResetSent(email));
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final TextStyle fieldStyle = t.typo.bodyLg.copyWith(
      color: t.colors.textPrimary,
    );
    final Widget card = AppCard(
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[
          const AppText(S.loginCardTitle, variant: TextVariant.titleMd),
          if (!kIsWeb)
            SegmentedControl<UserRole>(
              key: const Key('roleSelector'),
              fullWidth: true,
              value: _role,
              onChanged: (UserRole r) => setState(() => _role = r),
              options: const <SegmentOption<UserRole>>[
                SegmentOption<UserRole>(UserRole.patient, S.rolePatient),
                SegmentOption<UserRole>(
                  UserRole.nutritionist,
                  S.roleNutritionist,
                ),
              ],
            ),
          if (!kIsWeb)
            const AppText(
              S.roleHint,
              variant: TextVariant.caption,
              tone: TextTone.muted,
            ),
          TextField(
            key: const Key('emailField'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: fieldStyle,
            decoration: loginFieldDecoration(
              t,
              S.loginEmail,
              Icons.mail_outline_rounded,
            ),
          ),
          TextField(
            key: const Key('passwordField'),
            controller: _password,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
            style: fieldStyle,
            decoration: loginFieldDecoration(
              t,
              S.loginPassword,
              Icons.lock_outline_rounded,
            ),
          ),
          if (_error != null)
            AppText(
              _error!,
              key: const Key('authError'),
              variant: TextVariant.bodySm,
              tone: TextTone.danger,
            ),
          if (_info != null)
            AppText(
              _info!,
              key: const Key('authInfo'),
              variant: TextVariant.bodySm,
              tone: TextTone.success,
            ),
          AppButton(
            key: const Key('loginButton'),
            label: S.loginSubmit,
            fullWidth: true,
            loading: _loading,
            onPressed: _loading ? null : _signIn,
          ),
          AppButton(
            key: const Key('googleButton'),
            label: S.loginGoogle,
            variant: ButtonVariant.outlineAccent,
            fullWidth: true,
            onPressed: _loading ? null : _google,
          ),
        ],
      ),
    );
    final Widget actions = AppStack(
      gap: t.space.s2,
      children: <Widget>[
        AppButton(
          key: const Key('registerButton'),
          label: S.loginRegister,
          variant: ButtonVariant.outlineNeutral,
          fullWidth: true,
          onPressed: _loading ? null : _register,
        ),
        AppButton(
          key: const Key('forgotButton'),
          label: S.loginForgot,
          variant: ButtonVariant.ghost,
          fullWidth: true,
          onPressed: _loading ? null : _resetPassword,
        ),
      ],
    );
    final bool wide =
        kIsWeb && MediaQuery.sizeOf(context).width >= kWebWideBreakpoint;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
      child: Material(
        type: MaterialType.transparency,
        child: wide
            ? LoginWebLayout(card: card, actions: actions)
            : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    t.space.s5,
                    t.space.s8,
                    t.space.s5,
                    t.space.s8,
                  ),
                  child: AppStack(
                    gap: t.space.s5,
                    children: <Widget>[
                      const ScreenHeader(
                        eyebrow: S.loginEyebrow,
                        title: S.appName,
                      ),
                      const AppText(S.loginSubtitle, tone: TextTone.secondary),
                      card,
                      actions,
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
