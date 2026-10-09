import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/main_drawer.dart';
import 'activity.dart';
import 'progress.dart';
import 'swap.dart';
import 'today.dart';
import 'week.dart';

/// Pantalla principal del paciente: NavigationBar con 5 destinos.
/// El body es una lista y selectedIndex elige qué mostrar.
class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    // Redibuja la pantalla con la pestaña elegida.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    // Una pantalla por cada destino de la barra (mismo orden).
    final List<Widget> pages = [
      const WeekScreen(),
      TodayScreen(onGoToSwap: () => _selectPage(2)),
      const SwapScreen(),
      const ActivityScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      // El menú se abre desde la derecha, donde está el círculo de iniciales.
      endDrawer: const MainDrawer(isNutritionist: false),
      // extendBody deja que el contenido pase por detrás de la barra flotante.
      extendBody: true,
      // Muestra la pantalla de la pestaña seleccionada.
      body: pages[_selectedIndex],
      // SafeArea deja la barra arriba de la rayita del iPhone, y así la
      // NavigationBar no mete ese espacio dentro de la píldora.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
          child: Container(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: c.text.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: NavigationBar(
              // Qué pestaña se ve marcada.
              selectedIndex: _selectedIndex,
              // Al tocar una pestaña, cambia el índice.
              onDestinationSelected: _selectPage,
              backgroundColor: Colors.transparent,
              // Sin el óvalo de fondo, como en el mock.
              indicatorColor: Colors.transparent,
              elevation: 0,
              height: 74,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Semana',
                ),
                NavigationDestination(
                  icon: Icon(Icons.wb_sunny_outlined),
                  selectedIcon: Icon(Icons.wb_sunny),
                  label: 'Hoy',
                ),
                NavigationDestination(
                  icon: Icon(Icons.swap_horiz),
                  selectedIcon: Icon(Icons.swap_horizontal_circle),
                  label: 'Cambiar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.directions_walk_outlined),
                  selectedIcon: Icon(Icons.directions_run),
                  label: 'Actividad',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  // Badge: puntito rojo de "hay novedades".
                  selectedIcon: Badge(child: Icon(Icons.insights)),
                  label: 'Progreso',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
