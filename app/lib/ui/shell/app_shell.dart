import 'package:flutter/material.dart';

import '../../application/app_controllers.dart';
import '../../application/shell_controller.dart';
import '../../application/toast_controller.dart';
import '../../core/i18n/strings_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/data_display/app_toast.dart';
import '../components/domain/app_tab_bar.dart';
import '../components/primitives/app_icon.dart';
import '../screens/cambiar/cambiar_screen.dart';
import '../screens/hoy/hoy_screen.dart';
import '../screens/movimiento/movimiento_screen.dart';
import '../screens/progreso/progreso_screen.dart';
import '../screens/semana/semana_screen.dart';

/// Gradient background, safe area, the five tabs, the floating tab bar and
/// the toast overlay.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controllers});

  final AppControllers controllers;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final ShellController shell = controllers.shell;
    return ListenableBuilder(
      listenable: shell,
      builder: (BuildContext context, Widget? _) {
        final bool backClearsSwap =
            shell.tabIndex == ShellController.tabCambiar &&
            shell.pendingSwap != null;
        return PopScope(
          canPop: !backClearsSwap,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) shell.clearSwap();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
            child: Material(
              type: MaterialType.transparency,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: IndexedStack(
                        index: shell.tabIndex,
                        children: <Widget>[
                          SemanaScreen(controllers: controllers),
                          HoyScreen(controllers: controllers),
                          CambiarScreen(controllers: controllers),
                          MovimientoScreen(controllers: controllers),
                          ProgresoScreen(controllers: controllers),
                        ],
                      ),
                    ),
                    Positioned(
                      left: t.size.tabBarInset,
                      right: t.size.tabBarInset,
                      bottom: t.size.tabBarBottom,
                      child: AppTabBar(
                        active: shell.tabIndex,
                        onSelect: shell.selectTab,
                        items: const <AppTabItem>[
                          AppTabItem(AppIconName.calendar, S.tabSemana),
                          AppTabItem(AppIconName.today, S.tabHoy),
                          AppTabItem(AppIconName.swap, S.tabCambiar),
                          AppTabItem(AppIconName.activity, S.tabMovimiento),
                          AppTabItem(AppIconName.progress, S.tabProgreso),
                        ],
                      ),
                    ),
                    Positioned(
                      left: t.space.s5,
                      right: t.space.s5,
                      bottom:
                          t.size.tabBarBottom +
                          t.size.tabBarHeight +
                          t.space.s3,
                      child: _ToastHost(controller: controllers.toast),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToastHost extends StatelessWidget {
  const _ToastHost({required this.controller});

  final ToastController controller;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        final ToastMessage? m = controller.current;
        return AnimatedSwitcher(
          duration: reduce ? Duration.zero : t.motion.base,
          child: m == null
              ? const SizedBox.shrink(key: ValueKey<int>(0))
              : Center(
                  key: ValueKey<int>(m.id),
                  child: GestureDetector(
                    onTap: controller.dismiss,
                    child: AppToast(message: m.text),
                  ),
                ),
        );
      },
    );
  }
}
