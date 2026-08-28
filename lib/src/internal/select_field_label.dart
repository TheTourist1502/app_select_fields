import 'package:flutter/material.dart';

/// Caption above a select trigger field, greyed out when the field is
/// disabled. Shared by [AppSingleSelect] and [AppMultiSelect].
class SelectFieldLabel extends StatelessWidget {
  /// Creates a [SelectFieldLabel] showing [text].
  const SelectFieldLabel({
    required this.text,
    required this.enabled,
    this.style,
    this.required = false,
    super.key,
  });

  /// Label caption rendered above the field.
  final String text;

  /// Whether the owning field accepts input; drives the greyed-out colour.
  final bool enabled;

  /// Whether to append a red `*` marking the field as mandatory.
  final bool required;

  /// Optional override for the default label styling.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved =
        style ??
        (theme.textTheme.labelMedium ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)).copyWith(
          color: enabled ? theme.colorScheme.onSurface : theme.disabledColor,
        );

    if (!required) return Text(text, style: resolved);

    // RichText rather than two Text widgets in a Row so the `*` stays glued
    // to the label and wraps with it instead of being pushed onto its own
    // line.
    return RichText(
      text: TextSpan(
        style: resolved,
        children: [
          TextSpan(text: text),
          TextSpan(text: ' *', style: TextStyle(color: theme.colorScheme.error)),
        ],
      ),
    );
  }
}
