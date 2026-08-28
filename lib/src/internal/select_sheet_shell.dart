import 'package:flutter/material.dart';

import '../select_style.dart';
import 'select_search_field.dart';
import 'spacing.dart';

/// Container shell shared by the single- and multi-select bottom sheets.
///
/// Renders the drag handle, search field, optional [headerExtra] slot, the
/// scrollable [child] body and a bottom [actions] row.
class AppSelectSheetShell extends StatelessWidget {
  /// Builds the sheet chrome around a caller-supplied body and action row.
  const AppSelectSheetShell({
    required this.scrollController,
    required this.textController,
    required this.onQueryChanged,
    required this.child,
    required this.actions,
    required this.style,
    super.key,
    this.headerExtra,
    this.searchLoading = false,
  });

  /// Controller driving the sheet's draggable scroll body.
  final ScrollController scrollController;

  /// Backing controller for the search [TextField].
  final TextEditingController textController;

  /// Called on every keystroke in the search field, and with `''` when the
  /// field's own clear button empties it.
  final ValueChanged<String> onQueryChanged;

  /// Scrollable body filling the space between header and actions.
  final Widget child;

  /// Bottom action row (e.g. Cancel / OK buttons).
  final Widget actions;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  /// Optional extra header content below the search field.
  final Widget? headerExtra;

  /// Whether a server-side search is still running for the current query.
  final bool searchLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(style.sheetBorderRadius)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const _DragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(kSelectSpaceMd, kSelectSpaceXs, kSelectSpaceMd, kSelectSpaceSm),
              child: SelectSearchField(
                controller: textController,
                onChanged: onQueryChanged,
                hintText: style.searchHint,
                borderRadius: style.borderRadius,
                loading: searchLoading,
              ),
            ),
            ?headerExtra,
            const _Hairline(),
            Expanded(child: child),
            const _Hairline(),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSelectSpaceMd, vertical: kSelectSpaceSm + 4),
                child: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pill-shaped grab handle at the top of a select sheet.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: kSelectSpaceSm + 4, bottom: kSelectSpaceSm),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Thin full-width rule separating the sheet's header, body and actions.
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withValues(alpha: 0.6));
  }
}
