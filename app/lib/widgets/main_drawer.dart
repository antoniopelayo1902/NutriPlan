import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../screens/import_plan.dart';
import '../screens/profile.dart';
import '../screens/settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Menú lateral (Drawer). Lo usan el usuario y la nutrióloga.
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.isNutritionist});

  final bool isNutritionist;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final String name = isNutritionist ? nutritionistFullName : userName;
    final String initials = isNutritionist ? nutritionistInitials : userInitials;
    final String role = isNutritionist ? 'Nutrióloga' : 'Paciente de $nutritionistName';

    Widget item(IconData icon, String label, VoidCallback onTap) {
      return ListTile(
        leading: Icon(icon, color: c.text),
        title: Text(label, style: AppText.body(c)),
        onTap: onTap,
      );
    }

    return Drawer(
      backgroundColor: c.background,
      child: ListView(
        // Sin padding para que el encabezado llegue hasta arriba.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: c.accentBackground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.beige, borderRadius: BorderRadius.circular(28)),
                  child: Text(
                    initials,
                    style: AppText.body(c, weight: FontWeight.w600).copyWith(color: c.green),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: AppText.body(c, size: 20, weight: FontWeight.w600)),
                Text(role, style: AppText.kicker(c, color: c.textMuted).copyWith(fontSize: 16)),
              ],
            ),
          ),
          item(Icons.person_outline, 'Mi perfil', () {
            Navigator.pop(context); // cierra el Drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(isNutritionist: isNutritionist)),
            );
          }),
          item(Icons.settings_outlined, 'Ajustes', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          if (!isNutritionist)
            item(Icons.qr_code_2, 'Importar plan de mi nutrióloga', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ImportPlanScreen()));
            }),
          item(Icons.logout, 'Cerrar sesión', () {
            Navigator.pop(context); // cierra el Drawer
            Navigator.pop(context); // regresa al inicio de sesión
          }),
        ],
      ),
    );
  }
}
