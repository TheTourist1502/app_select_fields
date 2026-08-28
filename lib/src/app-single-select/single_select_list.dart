import 'package:flutter/material.dart';

import '../internal/no_records_found.dart';
import '../internal/spacing.dart';
import '../select_option.dart';
import '../select_style.dart';
import 'single_select_item.dart';

/// Scrollable option list for the single-select sheet.
///
/// Owns the scroll notification hook so pagination fires without rebuilding
/// the surrounding sheet chrome.
class SingleSelectList<T> extends StatelessWidget {
  /// Renders [options] plus an optional trailing loading row.
  const SingleSelectList({
    required this.scrollController,
    required this.options,
    required this.selectedValue,
    required this.showLoadingFooter,
    required this.onSelected,
    required this.onScrollNotification,
    required this.style,
    this.noRecordWidget,
    super.key,
  });

  /// Controller supplied by the draggable sheet.
  final ScrollController scrollController;

  /// Options to render, already filtered.
  final List<SelectOption<T>> options;

  /// Currently selected value, highlighted in the list.
  final T? selectedValue;

  /// Whether to append a spinner row while the next page loads.
  final bool showLoadingFooter;

  /// Called with the tapped option's value.
  final ValueChanged<T> onSelected;

  /// Forwarded to a [NotificationListener] to drive load-more.
  final bool Function(ScrollNotification) onScrollNotification;

  /// Style overrides shared with the rest of the select widget.
  final AppSelectStyle style;

  /// Shown instead of the list when [options] is empty. Defaults to a
  /// centered "No Records Found !" message.
  final Widget? noRecordWidget;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return noRecordWidget != null ? Center(child: noRecordWidget) : const NoRecordsFound();

    final itemCount = options.length + (showLoadingFooter ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: onScrollNotification,
      child: ListView.separated(
        controller: scrollController,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const _ItemSeparator(),
        itemBuilder: (_, i) {
          if (i >= options.length) return const _LoadingFooter();
          final option = options[i];
          return SingleSelectItem(
            label: option.label,
            selected: option.value == selectedValue,
            onTap: () => onSelected(option.value),
            style: style,
          );
        },
      ),
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
      indent: 54,
      endIndent: kSelectSpaceMd,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );
  }
}

/// Trailing spinner row shown while a further page is being fetched.
class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: kSelectSpaceMd),
      child: Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
