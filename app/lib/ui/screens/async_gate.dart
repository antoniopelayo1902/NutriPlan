import 'package:flutter/widgets.dart';

import '../../core/i18n/strings_es_mx.dart';
import '../../core/i18n/strings_flow_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/actions/app_button.dart';
import '../components/data_display/empty_state.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/skeleton.dart';

/// Shared loading / error / empty handling for a screen section.
class AsyncGate extends StatelessWidget {
  const AsyncGate({
    super.key,
    required this.loading,
    required this.hasError,
    required this.onRetry,
    required this.builder,
    this.empty = false,
    this.emptyTitle = S.noPlanTitle,
    this.emptyBody = S.noPlanBody,
    this.skeletons = 4,
  });

  final bool loading;
  final bool hasError;
  final VoidCallback onRetry;

  /// True when loading finished but there is nothing to show.
  final bool empty;
  final String emptyTitle;
  final String emptyBody;
  final int skeletons;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    if (loading) {
      return Semantics(
        label: SFlow.loadingLabel,
        liveRegion: true,
        child: ExcludeSemantics(
          child: AppStack(
            gap: t.space.s3,
            children: <Widget>[
              for (int i = 0; i < skeletons; i++)
                Skeleton(height: t.size.skeletonCard, radius: t.radius.xl),
            ],
          ),
        ),
      );
    }
    if (hasError) {
      return EmptyState(
        title: S.errorTitle,
        body: S.errorBody,
        action: AppButton(label: S.retry, onPressed: onRetry),
      );
    }
    if (empty) return EmptyState(title: emptyTitle, body: emptyBody);
    return builder(context);
  }
}
