import 'package:flutter/material.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/auth_service.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/data_display/screen_header.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';

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

  InputDecoration _decoration(AppTokens t, String label, IconData icon) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radius.md),
      borderSide: BorderSide(color: t.colors.borderDefault),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: t.typo.bodyMd.copyWith(color: t.colors.textMuted),
      prefixIcon: Icon(icon, color: t.colors.textMuted),
      filled: true,
      fillColor: t.colors.bgSurfaceSubtle,
      contentPadding: EdgeInsets.symmetric(
        horizontal: t.space.s4,
        vertical: t.space.s3,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(
          color: t.colors.accent,
          width: t.size.focusRingWidth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final TextStyle fieldStyle = t.typo.bodyLg.copyWith(
      color: t.colors.textPrimary,
    );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
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
                const ScreenHeader(eyebrow: S.loginEyebrow, title: S.appName),
                const AppText(S.loginSubtitle, tone: TextTone.secondary),
                AppCard(
                  child: AppStack(
                    gap: t.space.s3,
                    children: <Widget>[
                      const AppText(
                        S.loginCardTitle,
                        variant: TextVariant.titleMd,
                      ),
                      TextField(
                        key: const Key('emailField'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        style: fieldStyle,
                        decoration: _decoration(
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
                        decoration: _decoration(
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
                ),
                AppStack(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
