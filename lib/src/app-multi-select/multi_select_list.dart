import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../internal/no_records_found.dart';
import '../internal/spacing.dart';
import '../select_option.dart';
import '../select_style.dart';
import 'multi_select_item.dart';

/// Scrollable checkbox list for the multi-select sheet.
///
/// Stateless and independent of the selection set — each row subscribes to
/// [selection] on its own, so the list is not rebuilt on a toggle.
class MultiSelectList<T> extends StatelessWidget {
  /// Renders [options] as checkbox rows driven by [selection].
  const MultiSelectList({
    required this.scrollController,
    required this.options,
    required this.selection,
    required this.onToggle,
    required this.style,
    this.noRecordWidget,
    this.optionTemplate,
    super.key,
  });

  /// Controller supplied by the draggable sheet.
  final ScrollController scrollController;

  /// Options to render, already filtered.
  final List<SelectOption<T>> options;

  /// Live set of chosen values shared with every row.
  final ValueListenable<Set<T>> selection;

  /// Called with the tapped option's value.
  final ValueChanged<T> onToggle;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  /// Shown instead of the list when [options] is empty. Defaults to a
  /// centered "No Records Found !" message.
  final Widget? noRecordWidget;

  /// Builds each row's content in place of the default label [Text].
  final SelectOptionBuilder<T>? optionTemplate;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return noRecordWidget != null ? Center(child: noRecordWidget) : const NoRecordsFound();

    return ListView.separated(
      controller: scrollController,
      itemCount: options.length,
      separatorBuilder: (_, _) => const _ItemSeparator(),
      itemBuilder: (_, i) {
        final option = options[i];
        return MultiSelectItem<T>(
          label: option.label,
          value: option.value,
          selection: selection,
          onToggle: onToggle,
          style: style,
          optionTemplate: optionTemplate,
        );
      },
    );
  }
}

/// Inset hairline drawn between option rows.
class _ItemSeparator extends StatelessWidget {
  const _ItemSeparator();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      endIndent: kSelectSpaceMd,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );
  }
}
