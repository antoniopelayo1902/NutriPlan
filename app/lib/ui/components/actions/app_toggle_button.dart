import 'package:flutter/widgets.dart';

import 'app_button.dart';

/// "Marcar" <-> "Hecho": outline-neutral when off, primary when [pressed].
class AppToggleButton extends StatelessWidget {
  const AppToggleButton({
    super.key,
    required this.label,
    required this.pressed,
    required this.onPressed,
    this.size = ButtonSize.md,
    this.fullWidth = false,
  });

  final String label;
  final bool pressed;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      toggled: pressed,
      size: size,
      fullWidth: fullWidth,
      variant: pressed ? ButtonVariant.primary : ButtonVariant.outlineNeutral,
    );
  }
}
