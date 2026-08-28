import 'package:flutter/material.dart';

import '../select_style.dart';
import 'field_error_text.dart';

/// Common [InputDecoration] for the single- and multi-select trigger fields.
///
/// Colors come from the ambient [Theme]; [style] only supplies radius and
/// animation timing. Set [expanded] while the field's sheet is open — see
/// [SelectSheetToggle].
InputDecoration appSelectInputDecoration({
  required BuildContext context,
  required bool enabled,
  required AppSelectStyle style,
  String? errorText,
  bool loading = false,
  bool expanded = false,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final fill = theme.inputDecorationTheme.fillColor ?? colors.surface;
  final radius = BorderRadius.circular(style.borderRadius);
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  return InputDecoration(
    filled: true,
    fillColor: enabled ? fill : colors.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
    suffixIcon: loading
        ? Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: enabled ? colors.onSurfaceVariant : theme.disabledColor,
              ),
            ),
          )
        : AnimatedRotation(
            // Half a turn: the chevron points up while the sheet is open and
            // falls back down as it closes.
            turns: expanded ? 0.5 : 0,
            duration: reduceMotion ? Duration.zero : style.chevronAnimationDuration,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? colors.onSurfaceVariant : theme.disabledColor,
              size: 22,
            ),
          ),
    border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: colors.outlineVariant)),
    enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: colors.outlineVariant)),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: colors.error)),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.error, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.3)),
    ),
    // [errorText] is kept only for the red border and the error semantics —
    // the message itself is drawn by [FieldErrorText] under the field, at
    // zero start inset, so the decoration's own indented line is collapsed
    // away.
    errorText: errorText,
    errorStyle: kHiddenErrorStyle,
  );
}
