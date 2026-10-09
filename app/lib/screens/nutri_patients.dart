import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/measures.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/main_drawer.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_card.dart';
import 'nutri_patient.dart';

/// Inicio de la nutrióloga: lista de pacientes (ListView.builder).
class NutriPatientsScreen extends StatelessWidget {
  const NutriPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Scaffold(
      endDrawer: const MainDrawer(isNutritionist: true),
      // SafeArea: evita el notch.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: ScreenHeader(kicker: 'Consultorio', title: 'Mis pacientes', initials: nutritionistInitials),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
                // +1 para el botón "Agregar paciente" al final.
                itemCount: patients.length + 1,
                itemBuilder: (context, index) {
                  // El último elemento es el botón para agregar paciente.
                  if (index == patients.length) {
                    return PillButton(
                      label: 'Agregar paciente',
                      selected: true,
                      onPressed: () {
                        showPendingDialog(
                          context,
                          'Aquí podrás dar de alta un paciente nuevo con sus medidas de la primera consulta.',
                        );
                      },
                    );
                  }

                  final Patient patient = patients[index];
                  return SectionCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: c.beige, borderRadius: BorderRadius.circular(24)),
                        child: Text(
                          patient.initials,
                          style: AppText.body(c, size: 15, weight: FontWeight.w600).copyWith(color: c.green),
                        ),
                      ),
                      title: Text(patient.name, style: AppText.body(c, size: 18)),
                      subtitle: Text('${patient.age} años · ${patient.visit}', style: AppText.muted(c, size: 14)),
                      trailing: Icon(Icons.chevron_right, color: c.textFaint),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NutriPatientScreen(patient: patient)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
