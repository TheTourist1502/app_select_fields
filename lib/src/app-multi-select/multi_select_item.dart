import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../internal/spacing.dart';
import '../select_option.dart';
import '../select_style.dart';

/// One checkbox row in the multi-select sheet.
///
/// Watches [selection] itself and rebuilds only when *its own* membership
/// flips, so toggling one row never repaints the rest of the sheet.
class MultiSelectItem<T> extends StatefulWidget {
  /// Renders [label] with a checkbox reflecting membership in [selection].
  const MultiSelectItem({
    required this.label,
    required this.value,
    required this.selection,
    required this.onToggle,
    required this.style,
    super.key,
    this.optionTemplate,
  });

  /// Text shown for the option.
  final String label;

  /// Value this row represents.
  final T value;

  /// Live set of chosen values owned by the sheet.
  final ValueListenable<Set<T>> selection;

  /// Called with [value] when the row is tapped.
  final ValueChanged<T> onToggle;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  /// Builds this row's content in place of the default label [Text].
  final SelectOptionBuilder<T>? optionTemplate;

  @override
  State<MultiSelectItem<T>> createState() => _MultiSelectItemState<T>();
}

class _MultiSelectItemState<T> extends State<MultiSelectItem<T>> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selection.value.contains(widget.value);
    widget.selection.addListener(_syncSelected);
  }

  @override
  void didUpdateWidget(MultiSelectItem<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      oldWidget.selection.removeListener(_syncSelected);
      widget.selection.addListener(_syncSelected);
    }
    // A rebuild is already in flight, so assign without setState.
    _selected = widget.selection.value.contains(widget.value);
  }

  @override
  void dispose() {
    widget.selection.removeListener(_syncSelected);
    super.dispose();
  }

  /// Repaints this row only when its own membership actually changed.
  void _syncSelected() {
    final next = widget.selection.value.contains(widget.value);
    if (next != _selected) setState(() => _selected = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Material(
      color: _selected ? colors.primary.withValues(alpha: 0.07) : Colors.transparent,
      child: InkWell(
        onTap: () => widget.onToggle(widget.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSelectSpaceMd, vertical: kSelectSpaceSm + 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: reduceMotion ? Duration.zero : widget.style.checkAnimationDuration,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _selected ? colors.primary : Colors.transparent,
                  border: Border.all(
                    color: _selected ? colors.primary : colors.outline,
                    width: _selected ? 0 : 1.8,
                  ),
                ),
                child: _selected ? Icon(Icons.check, size: 15, color: colors.onPrimary) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child:
                    widget.optionTemplate?.call(context, widget.label, widget.value) ??
                    Text(
                      widget.label,
                      style: (widget.style.inputValueStyle ?? theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
                        color: _selected ? colors.primary : colors.onSurface,
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
