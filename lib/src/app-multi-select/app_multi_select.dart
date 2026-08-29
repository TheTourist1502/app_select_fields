import 'package:flutter/material.dart';

import '../internal/keyboard.dart';
import '../internal/select_field_label.dart';
import '../internal/spacing.dart';
import '../select_option.dart';
import '../select_style.dart';
import 'multi_select_sheet.dart';
import 'multi_select_trigger_field.dart';

/// A labelled input field that opens a **root-level draggable bottom sheet**
/// on tap, allowing the user to pick **one or more** options via styled
/// checkbox rows.
///
/// The sheet appears **above** the app's [AppBar] and bottom tab bar because
/// it uses `useRootNavigator: true`.
class AppMultiSelect<T> extends StatefulWidget {
  /// Creates a multi-select field; the caller owns [values].
  const AppMultiSelect({
    required this.label,
    required this.options,
    this.hint,
    this.values = const [],
    this.onChanged,
    this.maxSelectedLabel,
    this.enabled = true,
    this.validator,
    this.style = const AppSelectStyle(),
    this.noRecordWidget,
    this.displaySelectedCount = true,
    this.inputDecorationStyle,
    this.inputValueStyle,
    this.hintStyle,
    this.inputLabelStyle,
    this.selectedInputTemplate,
    this.optionTemplate,
    this.cancelButtonLabel,
    this.cancelButtonStyle,
    this.confirmButtonLabel,
    this.confirmButtonStyle,
    super.key,
  });

  /// Text shown above the field.
  final String label;

  /// Options offered in the sheet.
  final List<SelectOption<T>> options;

  /// Placeholder shown while nothing is selected.
  final String? hint;

  /// Currently selected values; the field is fully controlled by the caller.
  final List<T> values;

  /// Called with the confirmed values when the sheet closes.
  final ValueChanged<List<T>>? onChanged;

  /// When selected count exceeds this, shows "N selected" in the trigger.
  final int? maxSelectedLabel;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Form validator run against the selected values.
  final String? Function(List<T>?)? validator;

  /// Visual/copy overrides. Leave default to inherit the ambient [Theme].
  final AppSelectStyle style;

  /// Shown instead of the list when [options] is empty. Defaults to a
  /// centered "No Records Found !" message.
  final Widget? noRecordWidget;

  /// Whether the "N selected" summary chip shows above the option list.
  /// Defaults to `true`.
  final bool displaySelectedCount;

  /// Customizes the trigger field's resolved [InputDecoration]. Called with
  /// the package's default decoration; return a modified copy.
  final InputDecorationBuilder? inputDecorationStyle;

  /// Overrides the selected values' text style. Takes precedence over
  /// [AppSelectStyle.textStyle].
  final TextStyle? inputValueStyle;

  /// Overrides the placeholder's text style. Takes precedence over
  /// [AppSelectStyle.hintStyle].
  final TextStyle? hintStyle;

  /// Overrides the field label's text style. Takes precedence over
  /// [AppSelectStyle.labelStyle].
  final TextStyle? inputLabelStyle;

  /// Builds the trigger field's selected-value display in place of the
  /// default [Text]. Called once per selected option with its `label` and
  /// `value`, and laid out in a [Wrap]. Falls back to the default joined
  /// text once the selection count passes [maxSelectedLabel].
  final SelectOptionBuilder<T>? selectedInputTemplate;

  /// Builds each row's content in the option sheet in place of the default
  /// label [Text]. Called with that option's `label` and `value`.
  final SelectOptionBuilder<T>? optionTemplate;

  /// Overrides the sheet's Cancel button label. Takes precedence over
  /// [AppSelectStyle.cancelLabel].
  final String? cancelButtonLabel;

  /// Overrides the sheet's Cancel button style.
  final ButtonStyle? cancelButtonStyle;

  /// Overrides the sheet's confirm (OK) button label. Takes precedence over
  /// [AppSelectStyle.okLabel].
  final String? confirmButtonLabel;

  /// Overrides the sheet's confirm (OK) button style.
  final ButtonStyle? confirmButtonStyle;

  @override
  State<AppMultiSelect<T>> createState() => _AppMultiSelectState<T>();
}

class _AppMultiSelectState<T> extends State<AppMultiSelect<T>> {
  /// Lets [didUpdateWidget] push new controlled values into
  /// [FormFieldState] so the validator never sees a stale selection.
  final _fieldKey = GlobalKey<FormFieldState<List<T>>>();

  /// Cached trigger text, recomputed only when the inputs change rather than
  /// on every build. `null` means "render the N-selected label".
  String? _cachedDisplay = '';

  /// Cached selected options backing [AppMultiSelect.selectedInputTemplate].
  /// `null` under the same conditions as [_cachedDisplay].
  List<SelectOption<T>>? _cachedSelectedOptions;

  @override
  void initState() {
    super.initState();
    _cachedDisplay = _computeDisplay();
    _cachedSelectedOptions = _computeSelectedOptions();
  }

  @override
  void didUpdateWidget(AppMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values ||
        oldWidget.options != widget.options ||
        oldWidget.maxSelectedLabel != widget.maxSelectedLabel) {
      _cachedDisplay = _computeDisplay();
      _cachedSelectedOptions = _computeSelectedOptions();
      WidgetsBinding.instance.addPostFrameCallback((_) => _fieldKey.currentState?.didChange(widget.values));
    }
  }

  /// Joins the selected labels, or returns `null` once the count passes
  /// [AppMultiSelect.maxSelectedLabel].
  String? _computeDisplay() {
    if (widget.values.isEmpty) return '';
    final max = widget.maxSelectedLabel;
    if (max != null && widget.values.length > max) return null;
    final valSet = Set<T>.from(widget.values);
    return widget.options.where((o) => valSet.contains(o.value)).map((o) => o.label).join(', ');
  }

  /// The selected [SelectOption]s in order, or `null` once the count passes
  /// [AppMultiSelect.maxSelectedLabel] — same threshold as [_computeDisplay].
  List<SelectOption<T>>? _computeSelectedOptions() {
    if (widget.values.isEmpty) return const [];
    final max = widget.maxSelectedLabel;
    if (max != null && widget.values.length > max) return null;
    final valSet = Set<T>.from(widget.values);
    return widget.options.where((o) => valSet.contains(o.value)).toList();
  }

  /// Opens the picker sheet above the app chrome and reports the result.
  Future<void> _openSheet() async {
    // A text field elsewhere in the form may still hold focus; its keyboard
    // would sit over the sheet and be restored when the sheet closes.
    dismissKeyboard();
    final picked = await showModalBottomSheet<List<T>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.linear,
        reverseCurve: Curves.linear,
        duration: Duration(milliseconds: 280),
        reverseDuration: Duration(milliseconds: 220),
      ),
      builder: (_) => MultiSelectSheet<T>(
        options: widget.options,
        initialValues: List<T>.from(widget.values),
        style: widget.style,
        noRecordWidget: widget.noRecordWidget,
        displaySelectedCount: widget.displaySelectedCount,
        optionTemplate: widget.optionTemplate,
        cancelButtonLabel: widget.cancelButtonLabel,
        cancelButtonStyle: widget.cancelButtonStyle,
        confirmButtonLabel: widget.confirmButtonLabel,
        confirmButtonStyle: widget.confirmButtonStyle,
      ),
    );

    if (picked != null && widget.onChanged != null) {
      widget.onChanged!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = _cachedDisplay ?? widget.style.countLabel(widget.values.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectFieldLabel(
          text: widget.label,
          enabled: widget.enabled,
          style: widget.inputLabelStyle ?? widget.style.labelStyle,
        ),
        const SizedBox(height: kSelectSpaceSm),
        // IgnorePointer blocks touch to the entire subtree when disabled.
        IgnorePointer(
          ignoring: !widget.enabled,
          child: FormField<List<T>>(
            key: _fieldKey,
            initialValue: widget.values,
            validator: widget.validator,
            builder: (field) => MultiSelectTriggerField<T>(
              enabled: widget.enabled,
              onTap: _openSheet,
              display: display,
              selectedOptions: _cachedSelectedOptions,
              hint: widget.hint,
              errorText: field.errorText,
              style: widget.style,
              inputDecorationStyle: widget.inputDecorationStyle,
              inputValueStyle: widget.inputValueStyle,
              hintStyle: widget.hintStyle,
              selectedInputTemplate: widget.selectedInputTemplate,
            ),
          ),
        ),
      ],
    );
  }
}
