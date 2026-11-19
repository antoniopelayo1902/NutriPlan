import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/nutri_controller.dart';
import '../../domain/models/patient_summary.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../../theme/tokens_web.dart';
import 'nutri_web_sidebar.dart';
import 'web_no_selection.dart';
import '../screens/nutri/nutri_home_screen.dart';
import '../screens/nutri/nutri_patient_screen.dart';

/// Width from which the nutritionist gets the two-pane desktop layout.
const double kWebWideBreakpoint = 900;

/// Nutritionist home for wide screens (web): the patient list on the left
/// and the selected patient on the right. Narrow windows fall back to the
/// mobile list, so a phone browser behaves like the app.
class NutriWebShell extends StatefulWidget {
  const NutriWebShell({super.key});

  @override
  State<NutriWebShell> createState() => _NutriWebShellState();
}

class _NutriWebShellState extends State<NutriWebShell> {
  String? _selectedUid;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        if (box.maxWidth < kWebWideBreakpoint) return const NutriHomeScreen();
        final AppTokens t = context.tokens;
        final NutriController nutri = context.watch<NutriController>();
        PatientSummary? selected;
        for (final PatientSummary p in nutri.patients) {
          if (p.uid == _selectedUid) selected = p;
        }
        return Scaffold(
          backgroundColor: t.colors.transparent,
          body: DecoratedBox(
            decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: t.size.webSidebar,
                  child: ColoredBox(
                    color: t.colors.bgSurface,
                    child: NutriWebSidebar(
                      nutri: nutri,
                      selectedUid: _selectedUid,
                      onSelect: (PatientSummary p) =>
                          setState(() => _selectedUid = p.uid),
                    ),
                  ),
                ),
                VerticalDivider(
                  width: t.size.borderWidth,
                  thickness: t.size.borderWidth,
                  color: t.colors.divider,
                ),
                Expanded(
                  child: selected == null
                      ? WebNoSelection(hasPatients: nutri.patients.isNotEmpty)
                      // The key rebuilds the screen (and its controllers)
                      // when another patient is chosen.
                      : NutriPatientScreen(
                          key: ValueKey<String>(selected.uid),
                          patient: selected,
                          embedded: true,
                          onUnlinked: () => setState(() => _selectedUid = null),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
