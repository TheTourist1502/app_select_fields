import 'package:flutter/material.dart';

import '../internal/field_error_text.dart';
import '../internal/select_input_decoration.dart';
import '../internal/select_sheet_toggle.dart';
import '../select_style.dart';

/// The tappable, decorated field that opens the single-select sheet.
///
/// Shows the selected label or the hint; a separate widget so validator
/// rebuilds don't touch the surrounding form layout.
class SingleSelectTriggerField extends StatelessWidget {
  /// Not part of the public API — constructed only by [AppSingleSelect].
  const SingleSelectTriggerField({
    required this.enabled,
    required this.loading,
    required this.onTap,
    required this.style,
    super.key,
    this.selectedLabel,
    this.hint,
    this.errorText,
  });

  /// Whether the field accepts interaction and renders in full colour.
  final bool enabled;

  /// Whether to show a spinner in place of the chevron.
  final bool loading;

  /// Opens the option sheet; completes when the sheet closes, which is what
  /// drives the chevron back down.
  final Future<void> Function() onTap;

  /// Label of the current selection, or `null` when nothing is selected.
  final String? selectedLabel;

  /// Placeholder shown when [selectedLabel] is `null`.
  final String? hint;

  /// Validation message rendered under the field.
  final String? errorText;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectSheetToggle(
          onTap: onTap,
          builder: (context, expanded, handleTap) => GestureDetector(
            onTap: handleTap,
            child: InputDecorator(
              decoration: appSelectInputDecoration(
                context: context,
                enabled: enabled,
                loading: loading,
                style: style,
                errorText: errorText,
                expanded: expanded,
              ),
              child: Text(
                selectedLabel ?? hint ?? '',
                style: selectedLabel != null
                    // A caller-supplied colour applies only while enabled —
                    // a disabled field always greys out.
                    ? (style.textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        color: enabled ? (style.textStyle?.color ?? colors.onSurface) : theme.disabledColor,
                      )
                    : (style.hintStyle ?? theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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
}
