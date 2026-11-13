import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/toast_controller.dart';

import '../../core/i18n/strings_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/actions/app_icon_button.dart';
import '../components/data_display/screen_header.dart';
import '../components/data_display/toast_host.dart';
import '../components/primitives/app_icon.dart';
import '../components/primitives/app_stack.dart';

/// Pantalla que se abre con Navigator.push: fondo, botón de regresar y
/// encabezado iguales a las pestañas.
class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Scaffold(
      backgroundColor: t.colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: _scroll(context, t)),
              Positioned(
                left: t.space.s5,
                right: t.space.s5,
                bottom: t.space.s5,
                child: ToastHost(controller: context.read<ToastController>()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scroll(BuildContext context, AppTokens t) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        t.space.s5,
        t.space.s2,
        t.space.s5,
        t.space.s8,
      ),
      child: AppStack(
        gap: t.space.s5,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: AppIconButton(
              key: const Key('backButton'),
              icon: AppIconName.chevronLeft,
              variant: IconButtonVariant.outline,
              semanticLabel: S.back,
              // Navigator.pop regresa a la pantalla anterior.
              onPressed: () => Navigator.pop(context),
            ),
          ),
          ScreenHeader(eyebrow: eyebrow, title: title),
          ...children,
        ],
      ),
    );
  }
}
