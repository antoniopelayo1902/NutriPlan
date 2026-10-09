import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutriplan/main.dart';
import 'package:nutriplan/widgets/pill_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Prueba end to end de la Entrega 1: recorre todas las pantallas como lo
/// haría un usuario, presiona los botones y revisa que la interfaz cambie.
/// Correr con:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/app_test.dart -d SIMULADOR
void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(String name) async {
    await binding.takeScreenshot(name);
  }

  testWidgets('Recorrido completo de NutriPlan', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriPlanApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    /// Hace scroll hasta el widget y lo deja lejos de la barra de navegación
    /// flotante, para que el toque no le caiga a la barra.
    Future<void> tapVisible(Finder finder) async {
      // Un SnackBar abierto puede tapar el botón: lo quitamos primero.
      if (find.byType(SnackBar).evaluate().isNotEmpty) {
        ScaffoldMessenger.of(tester.element(find.byType(SnackBar).first)).removeCurrentSnackBar();
        await tester.pumpAndSettle();
      }
      // Si el ListView todavía no construye el widget, bajamos hasta encontrarlo.
      if (finder.evaluate().isEmpty) {
        await tester.dragUntilVisible(finder, find.byType(ListView).first, const Offset(0, -250));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      final double screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      if (tester.getCenter(finder).dy > screenHeight - 140) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -220));
        await tester.pumpAndSettle();
      }
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> goToTab(String label) async {
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
      await tester.pumpAndSettle();
    }

    Future<void> expectPendingAndClose() async {
      expect(find.text('Funcionalidad pendiente'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
    }

    // ---------------------------------------------------------------- Login
    expect(find.text('NutriPlan'), findsOneWidget);
    await shot('01_login');
    await tapVisible(find.text('Crear cuenta'));
    await expectPendingAndClose();
    await tapVisible(find.text('Olvidé contraseña'));
    await expectPendingAndClose();
    await tapVisible(find.text('Entrar'));

    // --------------------------------------------------------------- Semana
    expect(find.text('Mi semana'), findsOneWidget);
    await shot('02_semana');
    await tapVisible(find.byKey(const Key('mark-desayuno')));
    expect(find.text('Hecho ✓'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('day0')));
    await tester.pumpAndSettle();
    expect(find.text('Lunes 12'), findsOneWidget);
    await tester.tap(find.byKey(const Key('day4')));
    await tester.pumpAndSettle();
    expect(find.text('Viernes 16 · hoy'), findsOneWidget);

    // Cambiar la colación desde la tarjeta de Semana.
    await tapVisible(find.byKey(const Key('swap-colacion')));
    expect(find.text('Cambiar colación'), findsOneWidget);
    await shot('03_opciones_cambio');
    await tapVisible(find.widgetWithText(PillButton, 'Buscar otro alimento'));
    await expectPendingAndClose();
    await tapVisible(find.widgetWithText(PillButton, 'Elegir').first);
    expect(find.text('Manzana'), findsOneWidget);

    // ------------------------------------------------------------------ Hoy
    await goToTab('Hoy');
    // Se marcó el desayuno: 5 de 23 equivalentes = 22 %.
    expect(find.text('22% cubierto'), findsOneWidget);
    await shot('04_hoy');
    await tester.dragUntilVisible(
      find.byKey(const Key('swapsNote')),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    expect(find.textContaining('Llevas 4 intercambios'), findsOneWidget);
    await tapVisible(find.byKey(const Key('cravingButton')));
    expect(find.text('Cambiar colación'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // -------------------------------------------------------------- Cambiar
    await goToTab('Cambiar');
    expect(find.text('¿Otra cosa?'), findsOneWidget);
    await shot('05_cambiar');
    await tester.tap(find.text('Pescado empapelado con verduras'));
    await tester.pumpAndSettle();
    expect(find.text('Cambiar comida'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ------------------------------------------------------------ Actividad
    await goToTab('Actividad');
    expect(find.text('Movimiento'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    await shot('06_actividad');
    await tapVisible(find.byKey(const Key('quickYoga')));
    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('totalMinutes')), findsOneWidget);
    expect(find.text('180'), findsOneWidget);
    await tapVisible(find.byKey(const Key('removeActivity0')));
    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('145'), findsOneWidget);
    await tapVisible(find.widgetWithText(PillButton, 'Conectar con Salud de Apple'));
    await expectPendingAndClose();

    // ------------------------------------------------------------- Progreso
    await goToTab('Progreso');
    expect(find.text('88%'), findsOneWidget);
    await shot('07_progreso_semana');
    await tester.tap(find.text('Mes con mes'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('metricValue')), findsOneWidget);
    expect(find.text('71,2'), findsOneWidget);
    await shot('08_progreso_mes');
    await tester.tap(find.widgetWithText(ChoiceChip, '% de grasa'));
    await tester.pumpAndSettle();
    expect(find.text('34,8'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await shot('09_composicion');

    // --------------------------------------------------- Drawer y Ajustes
    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('avatarButton')));
    await tester.pumpAndSettle();
    await shot('10_menu');
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Modo oscuro'), findsOneWidget);
    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Modo oscuro'))).brightness, Brightness.dark);
    await shot('11_ajustes_oscuro');
    await tapVisible(find.text('Exportar mi historial'));
    await expectPendingAndClose();
    await tapVisible(find.text('Acerca de NutriPlan'));
    expect(find.text('NutriPlan · Entrega 1'), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await shot('12_progreso_oscuro');
    await goToTab('Semana');
    await shot('13_semana_oscuro');

    // Regresamos a modo claro.
    await tester.tap(find.byKey(const Key('avatarButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Modo oscuro'))).brightness, Brightness.light);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ------------------------------------------------------------- Perfil
    await tester.tap(find.byKey(const Key('avatarButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi perfil'));
    await tester.pumpAndSettle();
    expect(find.text('laura.mendez@correo.com'), findsOneWidget);
    await shot('14_perfil');
    await tapVisible(find.widgetWithText(PillButton, 'Editar perfil'));
    await expectPendingAndClose();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ------------------------------------------------------ Importar plan
    await tester.tap(find.byKey(const Key('avatarButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importar plan de mi nutrióloga'));
    await tester.pumpAndSettle();
    await shot('15_importar');
    await tapVisible(find.widgetWithText(PillButton, 'Abrir cámara'));
    await expectPendingAndClose();
    await tester.enterText(find.byKey(const Key('codeField')), 'hola');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tapVisible(find.widgetWithText(PillButton, 'Importar'));
    expect(find.textContaining('no es de NutriPlan'), findsOneWidget);
    await tester.tap(find.byKey(const Key('codeField')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('codeField')), 'NP1.abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tapVisible(find.widgetWithText(PillButton, 'Importar'));
    await expectPendingAndClose();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ------------------------------------------------------ Cerrar sesión
    await tester.tap(find.byKey(const Key('avatarButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Inicia sesión'), findsOneWidget);

    // ------------------------------------------------------- Nutrióloga
    await tapVisible(find.text('Nutriólogo(a)'));
    await tapVisible(find.text('Entrar'));
    expect(find.text('Mis pacientes'), findsOneWidget);
    await shot('16_pacientes');
    await tapVisible(find.widgetWithText(PillButton, 'Agregar paciente'));
    await expectPendingAndClose();
    await tester.tap(find.text('Laura Méndez'));
    await tester.pumpAndSettle();
    expect(find.text('Por llenar'), findsOneWidget);
    expect(find.text('27.1'), findsOneWidget); // IMC calculado: 71.2 / 1.62²
    await shot('17_nutri_medidas');
    await tester.tap(find.text('Pliegue tricipital'));
    await tester.pumpAndSettle();
    await expectPendingAndClose();

    await tester.tap(find.byKey(const Key('nutriTab1')));
    await tester.pumpAndSettle();
    expect(find.text('Peso · junio a septiembre'), findsOneWidget);
    await shot('18_nutri_historial');

    await tester.tap(find.byKey(const Key('nutriTab2')));
    await tester.pumpAndSettle();
    expect(find.text('1,450 kcal'), findsOneWidget);
    await tester.tap(find.byTooltip('Agregar Verduras'));
    await tester.pumpAndSettle();
    expect(find.text('1,475 kcal'), findsOneWidget);
    await tester.tap(find.byTooltip('Quitar Verduras'));
    await tester.pumpAndSettle();
    expect(find.text('1,450 kcal'), findsOneWidget);
    await shot('19_nutri_porciones');

    await tapVisible(find.text('Publicar plan a Laura'));
    expect(find.byType(QrImageView), findsOneWidget);
    await shot('20_qr');
    await tapVisible(find.widgetWithText(PillButton, 'Copiar código'));
    expect(find.textContaining('Código copiado'), findsOneWidget);
    await tapVisible(find.widgetWithText(PillButton, 'Enviar a Laura'));
    await expectPendingAndClose();
  });
}
