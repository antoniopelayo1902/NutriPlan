import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';

/// Interaction state handed to the builder of a [Pressable].
class PressState {
  const PressState({
    required this.pressed,
    required this.hovered,
    required this.focused,
    required this.enabled,
  });

  final bool pressed;
  final bool hovered;

  /// True only for keyboard focus (focus-visible).
  final bool focused;
  final bool enabled;
}

/// Shared tappable behavior: hit area (at least 48x48), pressed scale,
/// hover, keyboard focus and semantics. Every tappable component uses it.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.minWidth,
    this.minHeight,
    this.stretch = false,
  });

  final Widget Function(BuildContext context, PressState state) builder;
  final VoidCallback? onPressed;

  /// Overrides the label read from descendants.
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;

  /// Minimum hit box; defaults to the `hitMin` token for both axes.
  final double? minWidth;
  final double? minHeight;

  /// Take all horizontal space offered by the parent.
  final bool stretch;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  void _set({bool? pressed, bool? hovered, bool? focused}) {
    setState(() {
      _pressed = pressed ?? _pressed;
      _hovered = hovered ?? _hovered;
      _focused = focused ?? _focused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final PressState state = PressState(
      pressed: _pressed && _enabled,
      hovered: _hovered && _enabled,
      focused: _focused && _enabled,
      enabled: _enabled,
    );
    Widget core = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minWidth ?? t.size.hitMin,
        minHeight: widget.minHeight ?? t.size.hitMin,
      ),
      child: Center(
        widthFactor: widget.stretch ? null : 1,
        heightFactor: 1,
        child: AnimatedScale(
          scale: state.pressed ? t.size.pressedScale : 1,
          duration: reduce ? Duration.zero : t.motion.fast,
          curve: t.motion.easeOut,
          child: widget.builder(context, state),
        ),
      ),
    );
    core = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => _set(pressed: true) : null,
      onTapCancel: _enabled ? () => _set(pressed: false) : null,
      onTapUp: _enabled ? (_) => _set(pressed: false) : null,
      onTap: widget.onPressed,
      child: core,
    );
    core = FocusableActionDetector(
      enabled: _enabled,
      mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowHoverHighlight: (bool v) => _set(hovered: v),
      onShowFocusHighlight: (bool v) => _set(focused: v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: core,
    );
    final Widget semantic = Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      excludeSemantics: widget.semanticLabel != null,
      child: core,
    );
    return widget.semanticLabel == null
        ? MergeSemantics(child: semantic)
        : semantic;
  }
}
