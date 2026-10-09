import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Fila deslizable de filtros: "Peso", "% de grasa", "Masa muscular"...
///
/// Usa ChoiceChip.
/// Es una "pastilla" seleccionable; solo una puede estar activa a la vez.
class MetricChips extends StatelessWidget {
  const MetricChips({super.key, required this.names, required this.selectedIndex, required this.onSelected});

  final List<String> names;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return SizedBox(
      height: 50,
      // ListView horizontal para poder deslizar los filtros.
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        itemBuilder: (context, index) {
          final bool selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(names[index]),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                onSelected(index);
              },
              selectedColor: c.inverse,
              backgroundColor: c.card,
              labelStyle: AppText.body(c, size: 16).copyWith(color: selected ? c.onInverse : c.text),
              shape: StadiumBorder(side: BorderSide(color: selected ? c.inverse : c.border)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          );
        },
      ),
    );
  }
}
