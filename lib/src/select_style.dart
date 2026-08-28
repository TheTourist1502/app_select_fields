import 'package:flutter/material.dart';

/// Optional visual/copy overrides for [AppSingleSelect] and [AppMultiSelect].
///
/// Both widgets read colors and text styles from the ambient [Theme] by
/// default (M3 [ColorScheme] / [TextTheme]), so no [AppSelectStyle] is needed
/// to get a look consistent with the host app. Pass one only to change a
/// specific corner radius, animation timing, or one of the built-in English
/// strings (search hint, button labels, "N selected").
@immutable
class AppSelectStyle {
  /// Creates a style override. Every field falls back to a Material 3
  /// default or an English string when left unset.
  const AppSelectStyle({
    this.borderRadius = 12,
    this.sheetBorderRadius = 20,
    this.chevronAnimationDuration = const Duration(milliseconds: 150),
    this.checkAnimationDuration = const Duration(milliseconds: 180),
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.searchHint = 'Search',
    this.cancelLabel = 'Cancel',
    this.clearLabel = 'Clear',
    this.okLabel = 'OK',
    this.selectedCountLabel,
  });

  /// Corner radius of the trigger field's border.
  final double borderRadius;

  /// Corner radius of the top corners of the option sheet.
  final double sheetBorderRadius;

  /// How long the trigger's chevron takes to flip when the sheet opens.
  /// Skipped automatically when the platform's reduce-motion setting is on.
  final Duration chevronAnimationDuration;

  /// How long a radio dot / checkbox takes to animate to its new state.
  /// Skipped automatically when the platform's reduce-motion setting is on.
  final Duration checkAnimationDuration;

  /// Overrides the caption above the field. Defaults to
  /// `Theme.of(context).textTheme.labelMedium`.
  final TextStyle? labelStyle;

  /// Overrides the placeholder shown while nothing is selected. Defaults to
  /// `Theme.of(context).textTheme.bodyMedium`.
  final TextStyle? hintStyle;

  /// Overrides the selected value's text style. Defaults to
  /// `Theme.of(context).textTheme.bodyMedium`.
  final TextStyle? textStyle;

  /// Placeholder text for the sheet's search field.
  final String searchHint;

  /// Label of the button that closes the sheet without changing anything.
  final String cancelLabel;

  /// Label of the button that clears the current selection.
  final String clearLabel;

  /// Label of the button that confirms a multi-select's choices.
  final String okLabel;

  /// Builds the "N selected" summary shown once a multi-select's count
  /// exceeds its `maxSelectedLabel`, or the header chip's caption. Defaults
  /// to `'$count selected'`.
  final String Function(int count)? selectedCountLabel;

  /// Resolves [selectedCountLabel], falling back to the English default.
  String countLabel(int count) => selectedCountLabel?.call(count) ?? '$count selected';
}
