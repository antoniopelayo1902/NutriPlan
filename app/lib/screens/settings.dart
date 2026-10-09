import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/section_card.dart';

/// Ajustes de la app. El modo oscuro sí funciona: cambia el tema de toda
/// la app a través de SettingsProvider.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    Widget divider() => Container(height: 1, color: c.border);

    // Renglón con ícono, texto y un Switch a la derecha.
    Widget switchTile({
      Key? key,
      required IconData icon,
      required String title,
      String? subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: c.text),
        title: Text(title, style: AppText.body(c)),
        subtitle: subtitle == null ? null : Text(subtitle, style: AppText.muted(c, size: 14)),
        trailing: Switch(
          key: key,
          value: value,
          activeThumbColor: c.onInverse,
          activeTrackColor: c.green,
          onChanged: onChanged,
        ),
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.background,
            foregroundColor: c.text,
            elevation: 0,
            title: Text('Ajustes', style: AppText.body(c, size: 18)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
            children: [
              Text('Personaliza', style: AppText.kicker(c)),
              Text('Ajustes', style: AppText.title(c)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Text('Apariencia', style: AppText.cardLabel(c)),
              ),
              SectionCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: switchTile(
                  key: const Key('darkModeSwitch'),
                  icon: Icons.dark_mode_outlined,
                  title: 'Modo oscuro',
                  subtitle: 'Cambia los colores de toda la app',
                  value: settings.darkMode,
                  onChanged: (value) {
                    // Cambia el tema de toda la app (Provider avisa a MaterialApp).
                    settings.setDarkMode(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Text('Recordatorios', style: AppText.cardLabel(c)),
              ),
              SectionCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Column(
                  children: [
                    switchTile(
                      icon: Icons.restaurant_outlined,
                      title: 'Avisarme de cada comida',
                      value: settings.mealReminders,
                      onChanged: (value) {
                        settings.setMealReminders(value);
                        showPendingDialog(
                          context,
                          'Aquí se programarán notificaciones a la hora de cada comida de tu plan.',
                        );
                      },
                    ),
                    divider(),
                    switchTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Recordarme tomar agua',
                      value: settings.waterReminders,
                      onChanged: (value) {
                        settings.setWaterReminders(value);
                        showPendingDialog(context, 'Aquí se programará un recordatorio de agua cada 2 horas.');
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Text('Datos', style: AppText.cardLabel(c)),
              ),
              SectionCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.file_download_outlined, color: c.text),
                      title: Text('Exportar mi historial', style: AppText.body(c)),
                      onTap: () {
                        showPendingDialog(context, 'Aquí se generará un PDF con tu historial para tu nutrióloga.');
                      },
                    ),
                    divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline, color: c.accent),
                      title: Text('Borrar mis datos', style: AppText.body(c).copyWith(color: c.accent)),
                      onTap: () {
                        showPendingDialog(context, 'Aquí se borrarán todos tus datos guardados en el teléfono.');
                      },
                    ),
                    divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.info_outline, color: c.text),
                      title: Text('Acerca de NutriPlan', style: AppText.body(c)),
                      onTap: () {
                        // Dialog con la información de la app.
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: c.card,
                            title: Text('NutriPlan · Entrega 1', style: AppText.body(c, size: 20)),
                            content: Text(
                              'Proyecto de Programación de Dispositivos Móviles, ITESO. '
                              'La información es orientativa y no sustituye la consulta con un profesional.',
                              style: AppText.muted(c),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
