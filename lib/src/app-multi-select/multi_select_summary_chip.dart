import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../internal/spacing.dart';
import '../select_style.dart';

/// Header chip showing how many options are selected, with a clear action.
///
/// Rebuilds off [selection] alone so the sheet chrome around it stays put;
/// renders nothing while the selection is empty.
class MultiSelectSummaryChip<T> extends StatelessWidget {
  /// Displays the count in [selection] and calls [onClear] when dismissed.
  const MultiSelectSummaryChip({required this.selection, required this.onClear, required this.style, super.key});

  /// Live set of chosen values owned by the sheet.
  final ValueListenable<Set<T>> selection;

  /// Clears the whole selection.
  final VoidCallback onClear;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ValueListenableBuilder<Set<T>>(
      valueListenable: selection,
      builder: (context, selected, _) {
        if (selected.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(kSelectSpaceMd, kSelectSpaceXs, kSelectSpaceMd, kSelectSpaceSm),
          child: Row(
            children: [
              Chip(
                label: Text(
                  style.countLabel(selected.length),
                  style: (theme.textTheme.labelSmall ?? const TextStyle(fontSize: 12)).copyWith(
                    color: colors.primary,
                  ),
                ),
                deleteIcon: Icon(Icons.close, size: 14, color: colors.primary),
                onDeleted: onClear,
                side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                backgroundColor: colors.primary.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(horizontal: kSelectSpaceXs),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        );
      },
    );
  }
}
