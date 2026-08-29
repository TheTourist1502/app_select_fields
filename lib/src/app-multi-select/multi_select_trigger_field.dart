import 'package:flutter/material.dart';

import '../internal/field_error_text.dart';
import '../internal/select_input_decoration.dart';
import '../internal/select_sheet_toggle.dart';
import '../select_option.dart';
import '../select_style.dart';

/// The tappable, decorated field that opens the multi-select sheet.
///
/// A widget rather than a `FormField` builder closure, so validator rebuilds
/// don't touch the surrounding form layout.
class MultiSelectTriggerField<T> extends StatelessWidget {
  /// Not part of the public API — constructed only by [AppMultiSelect].
  const MultiSelectTriggerField({
    required this.enabled,
    required this.onTap,
    required this.display,
    required this.style,
    super.key,
    this.selectedOptions,
    this.hint,
    this.errorText,
    this.inputDecorationStyle,
    this.inputValueStyle,
    this.hintStyle,
    this.selectedInputTemplate,
  });

  /// Whether the field renders in full colour.
  final bool enabled;

  /// Opens the option sheet; completes when the sheet closes, which is what
  /// drives the chevron back down.
  final Future<void> Function() onTap;

  /// Resolved summary of the current selection; empty shows [hint].
  final String display;

  /// The selected options backing [selectedInputTemplate], in order. `null`
  /// once the selection count exceeds `maxSelectedLabel` — [display] (the
  /// "N selected" text) is used instead in that case.
  final List<SelectOption<T>>? selectedOptions;

  /// Placeholder shown when nothing is selected.
  final String? hint;

  /// Validation message rendered under the field.
  final String? errorText;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  /// Customizes the trigger's resolved [InputDecoration].
  final InputDecorationBuilder? inputDecorationStyle;

  /// Overrides the selected values' text style. Takes precedence over
  /// [AppSelectStyle.inputValueStyle].
  final TextStyle? inputValueStyle;

  /// Overrides the placeholder's text style. Takes precedence over
  /// [AppSelectStyle.hintStyle].
  final TextStyle? hintStyle;

  /// Builds each selected option's display, laid out in a [Wrap], in place
  /// of the default joined-label [Text].
  final SelectOptionBuilder<T>? selectedInputTemplate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasValue = display.isNotEmpty;
    final options = selectedOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectSheetToggle(
          onTap: onTap,
          builder: (context, expanded, handleTap) => GestureDetector(
            onTap: handleTap,
            child: InputDecorator(
              decoration: _resolveDecoration(context, expanded),
              child: hasValue && options != null && options.isNotEmpty && selectedInputTemplate != null
                  ? Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final option in options) selectedInputTemplate!(context, option.label, option.value),
                      ],
                    )
                  : Text(
                      hasValue ? display : (hint ?? ''),
                      style: hasValue
                          ? (inputValueStyle ?? style.inputValueStyle ?? theme.textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(color: enabled ? colors.onSurface : theme.disabledColor)
                          : (hintStyle ?? style.hintStyle ?? theme.textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(color: colors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ),
        // Drawn outside the decoration so it starts at the field's left edge
        // rather than at the content padding. See [FieldErrorText].
        if (errorText case final error?) FieldErrorText(message: error, excludeSemantics: true),
      ],
    );
  }

  InputDecoration _resolveDecoration(BuildContext context, bool expanded) {
    final decoration = appSelectInputDecoration(
      context: context,
      enabled: enabled,
      style: style,
      errorText: errorText,
      expanded: expanded,
    );
    return (inputDecorationStyle ?? style.inputDecorationStyle)?.call(decoration) ?? decoration;
  }
}
