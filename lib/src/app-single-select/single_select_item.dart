import 'package:flutter/material.dart';

import '../internal/spacing.dart';
import '../select_style.dart';

/// One radio-style row in the single-select sheet.
///
/// Its own widget class so a selection change repaints only the affected
/// rows rather than the whole list.
class SingleSelectItem extends StatelessWidget {
  /// Renders [label] with a radio indicator reflecting [selected].
  const SingleSelectItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.style,
    super.key,
  });

  /// Text shown for the option.
  final String label;

  /// Whether this row is the currently chosen option.
  final bool selected;

  /// Invoked when the row is tapped.
  final VoidCallback onTap;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSelectSpaceMd, vertical: 15),
          child: Row(
            children: [
              AnimatedContainer(
                duration: reduceMotion ? Duration.zero : style.checkAnimationDuration,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outline,
                    width: selected ? 7 : 2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: (style.textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? colors.primary : colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
