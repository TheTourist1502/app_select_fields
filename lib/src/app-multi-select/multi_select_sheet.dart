import 'package:flutter/material.dart';

import '../internal/select_sheet_shell.dart';
import '../internal/spacing.dart';
import '../select_option.dart';
import '../select_style.dart';
import 'multi_select_list.dart';
import 'multi_select_summary_chip.dart';

/// Internal bottom sheet for [AppMultiSelect].
///
/// Pops the confirmed values, or `null` on cancel. Selection lives in a
/// [ValueNotifier] so a toggle repaints only the affected row and the chip.
class MultiSelectSheet<T> extends StatefulWidget {
  /// Not part of the public API — constructed only by [AppMultiSelect].
  const MultiSelectSheet({
    required this.options,
    required this.initialValues,
    required this.style,
    super.key,
    this.noRecordWidget,
    this.displaySelectedCount = true,
    this.optionTemplate,
    this.cancelButtonLabel,
    this.cancelButtonStyle,
    this.confirmButtonLabel,
    this.confirmButtonStyle,
  });

  /// Options offered in the sheet.
  final List<SelectOption<T>> options;

  /// Values pre-selected when the sheet opens.
  final List<T> initialValues;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  /// Shown instead of the list when there are no options. Defaults to a
  /// centered "No Records Found !" message.
  final Widget? noRecordWidget;

  /// Whether the "N selected" summary chip shows above the option list.
  final bool displaySelectedCount;

  /// Builds each row's content in place of the default label [Text].
  final SelectOptionBuilder<T>? optionTemplate;

  /// Overrides the Cancel button's label. Takes precedence over
  /// [AppSelectStyle.cancelLabel].
  final String? cancelButtonLabel;

  /// Overrides the Cancel button's style.
  final ButtonStyle? cancelButtonStyle;

  /// Overrides the confirm (OK) button's label. Takes precedence over
  /// [AppSelectStyle.okLabel].
  final String? confirmButtonLabel;

  /// Overrides the confirm (OK) button's style.
  final ButtonStyle? confirmButtonStyle;

  @override
  State<MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<MultiSelectSheet<T>> {
  /// Insertion-ordered, so `toList()` reproduces the tap order exactly.
  late final ValueNotifier<Set<T>> _selection;

  final TextEditingController _textController = TextEditingController();
  String _query = '';

  List<SelectOption<T>>? _cachedFiltered;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    _selection = ValueNotifier(Set<T>.from(widget.initialValues));
  }

  @override
  void dispose() {
    _textController.dispose();
    _selection.dispose();
    super.dispose();
  }

  /// Filters options by label, memoised so sheet drags don't re-filter.
  List<SelectOption<T>> get _filtered {
    if (_lastQuery == _query && _cachedFiltered != null) return _cachedFiltered!;
    _lastQuery = _query;
    _cachedFiltered = _query.isEmpty
        ? widget.options
        : widget.options.where((o) => o.label.toLowerCase().contains(_query.toLowerCase())).toList();
    return _cachedFiltered!;
  }

  /// Adds or removes [value], publishing a new set so listeners fire.
  void _toggle(T value) {
    final next = Set<T>.from(_selection.value);
    if (!next.remove(value)) next.add(value);
    _selection.value = next;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 0.75, 0.95],
      builder: (ctx, scrollController) {
        return AppSelectSheetShell(
          scrollController: scrollController,
          textController: _textController,
          onQueryChanged: (v) => setState(() => _query = v),
          style: widget.style,
          headerExtra: widget.displaySelectedCount
              ? MultiSelectSummaryChip<T>(
                  selection: _selection,
                  onClear: () => _selection.value = <T>{},
                  style: widget.style,
                )
              : null,
          actions: _SheetActions(
            style: widget.style,
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: () => Navigator.of(context).pop(_selection.value.toList()),
            cancelButtonLabel: widget.cancelButtonLabel,
            cancelButtonStyle: widget.cancelButtonStyle,
            confirmButtonLabel: widget.confirmButtonLabel,
            confirmButtonStyle: widget.confirmButtonStyle,
          ),
          child: MultiSelectList<T>(
            scrollController: scrollController,
            options: _filtered,
            selection: _selection,
            onToggle: _toggle,
            style: widget.style,
            noRecordWidget: widget.noRecordWidget,
            optionTemplate: widget.optionTemplate,
          ),
        );
      },
    );
  }
}

/// Cancel / OK row at the bottom of the multi-select sheet.
class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.onCancel,
    required this.onConfirm,
    required this.style,
    this.cancelButtonLabel,
    this.cancelButtonStyle,
    this.confirmButtonLabel,
    this.confirmButtonStyle,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final AppSelectStyle style;

  /// Overrides the Cancel button's label. Takes precedence over
  /// [AppSelectStyle.cancelLabel].
  final String? cancelButtonLabel;

  /// Overrides the Cancel button's style.
  final ButtonStyle? cancelButtonStyle;

  /// Overrides the confirm (OK) button's label. Takes precedence over
  /// [AppSelectStyle.okLabel].
  final String? confirmButtonLabel;

  /// Overrides the confirm (OK) button's style.
  final ButtonStyle? confirmButtonStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: onCancel,
            style: cancelButtonStyle,
            child: Text(cancelButtonLabel ?? style.cancelLabel),
          ),
        ),
        const SizedBox(width: kSelectSpaceMd),
        Expanded(
          child: FilledButton(
            onPressed: onConfirm,
            style: confirmButtonStyle,
            child: Text(confirmButtonLabel ?? style.okLabel),
          ),
        ),
      ],
    );
  }
}
