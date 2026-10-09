import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_card.dart';

/// Perfil: datos del usuario (o de la nutrióloga) y sus metas.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.isNutritionist});

  final bool isNutritionist;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    final Map<String, String> data = isNutritionist
        ? {
            'Nombre': nutritionistFullName,
            'Cédula profesional': '12345678',
            'Pacientes activos': '${patients.length}',
            'Consultorio': 'Guadalajara, Jal.',
          }
        : {
            'Nombre': userName,
            'Correo': userEmail,
            'Edad': '34 años',
            'Peso': '71.2 kg',
            'Talla': '1.62 m',
            'Objetivo': 'Bajar de peso',
            'Meta de agua': '8 vasos al día',
            'Mi nutrióloga': nutritionistFullName,
          };

    final List<Widget> rows = [];
    // Un renglón por cada dato del perfil.
    data.forEach((label, value) {
      if (rows.isNotEmpty) {
        rows.add(Container(height: 1, color: c.border));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.muted(c, size: 16)),
              Text(value, style: AppText.body(c, size: 16, weight: FontWeight.w600)),
            ],
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        title: Text('Mi perfil', style: AppText.body(c, size: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          Text(isNutritionist ? 'Nutrióloga' : 'Paciente', style: AppText.kicker(c)),
          Text(isNutritionist ? nutritionistFullName : userName, style: AppText.title(c)),
          const SizedBox(height: 20),
          SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
            child: Column(children: rows),
          ),
          PillButton(
            label: 'Editar perfil',
            selected: true,
            onPressed: () {
              showPendingDialog(context, 'Aquí podrás editar tus datos. Los cambios se guardarán en la base de datos.');
            },
          ),
        ],
      ),
    );
  }
}
