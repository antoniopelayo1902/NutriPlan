import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_card.dart';
import 'nutri_patients.dart';
import 'tabs.dart';

/// Pantalla de inicio de sesión. La autenticación todavía no existe:
/// el botón "Entrar" solo navega según el rol elegido.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'laura.mendez@correo.com');
  final TextEditingController _passwordController = TextEditingController(text: '12345678');
  String _role = 'usuario'; // 'usuario' o 'nutriologo'

  @override
  void dispose() {
    // Liberamos los controladores cuando la pantalla se destruye (ciclo de vida).
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Validación simple: no deja entrar con campos vacíos.
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showInfoSnackBar(context, 'Escribe tu correo y tu contraseña.');
      return;
    }

    Widget destination = const TabsScreen();
    if (_role == 'nutriologo') {
      destination = const NutriPatientsScreen();
    }
    // Agrega la pantalla elegida a la pila (con pop regresamos aquí).
    Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
  }

  InputDecoration _inputDecoration(AppColors c, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: c.textMuted),
      filled: true,
      fillColor: c.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Scaffold(
      // SafeArea: evita que el contenido quede debajo del notch.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: const DecorationImage(image: AssetImage('assets/icon/app_icon.png')),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Bienvenida a', textAlign: TextAlign.center, style: AppText.kicker(c)),
            Text('NutriPlan', textAlign: TextAlign.center, style: AppText.title(c).copyWith(fontSize: 48)),
            const SizedBox(height: 6),
            Text(
              'Tu plan de alimentación por equivalentes, siempre a la mano.',
              textAlign: TextAlign.center,
              style: AppText.muted(c),
            ),
            const SizedBox(height: 28),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inicia sesión', style: AppText.cardLabel(c)),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(c, 'Correo', Icons.mail_outline),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    // Oculta la contraseña con puntitos.
                    obscureText: true,
                    decoration: _inputDecoration(c, 'Contraseña', Icons.lock_outline),
                  ),
                  const SizedBox(height: 10),
                  Text('Entro como', style: AppText.muted(c, size: 14)),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Paciente', style: AppText.body(c, size: 16)),
                    value: 'usuario',
                    groupValue: _role,
                    activeColor: c.accent,
                    onChanged: (value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Nutriólogo(a)', style: AppText.body(c, size: 16)),
                    value: 'nutriologo',
                    groupValue: _role,
                    activeColor: c.accent,
                    onChanged: (value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(label: 'Entrar', selected: true, onPressed: _login),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Crear cuenta',
                    onPressed: () {
                      showPendingDialog(
                        context,
                        'Aquí podrás crear tu cuenta con correo y contraseña. Se guardará en la base de datos.',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PillButton(
                    label: 'Olvidé contraseña',
                    fontSize: 14,
                    onPressed: () {
                      showPendingDialog(context, 'Aquí te enviaremos un correo para recuperar tu contraseña.');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
