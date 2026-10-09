import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Encabezado de cada pantalla, igual a los mocks:
/// título pequeño en cursiva, título grande y el círculo con iniciales.
/// Al tocar las iniciales se abre el menú lateral (Drawer).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.kicker,
    required this.title,
    this.initials,
    this.subtitle,
    this.kickerColor,
  });

  final String kicker;
  final String title;
  final String? initials; // null = sin círculo de iniciales
  final String? subtitle;
  final Color? kickerColor;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker, style: AppText.kicker(c, color: kickerColor)),
                Text(title, style: AppText.title(c)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(subtitle!, style: AppText.muted(c)),
                  ),
              ],
            ),
          ),
          if (initials != null)
            IconButton(
              key: const Key('avatarButton'),
              tooltip: 'Abrir menú',
              onPressed: () {
                // El Drawer está en el Scaffold de las pestañas (lado derecho).
                Scaffold.of(context).openEndDrawer();
              },
              icon: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.beige, borderRadius: BorderRadius.circular(26)),
                child: Text(
                  initials!,
                  style: AppText.body(c, size: 16, weight: FontWeight.w600).copyWith(color: c.green),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
