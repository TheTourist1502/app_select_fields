import 'package:flutter/material.dart';

/// Tracks whether the sheet a select trigger opens is on screen, so the
/// trigger's chevron can point up for as long as it is.
///
/// [onTap] must be the call that completes when the sheet closes — every
/// select trigger's open method already returns that future.
class SelectSheetToggle extends StatefulWidget {
  /// Creates a [SelectSheetToggle].
  const SelectSheetToggle({required this.onTap, required this.builder, super.key});

  /// Opens the sheet; its future completes when the sheet is dismissed.
  final Future<void> Function() onTap;

  /// Builds the trigger with the current open state and the tap callback
  /// that maintains it. Pass `onTap` on rather than [widget.onTap], or the
  /// state never flips.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(BuildContext context, bool expanded, VoidCallback onTap) builder;

  @override
  State<SelectSheetToggle> createState() => _SelectSheetToggleState();
}

class _SelectSheetToggleState extends State<SelectSheetToggle> {
  /// A notifier rather than `setState` so only the trigger rebuilds, not the
  /// form row around it.
  final ValueNotifier<bool> _expanded = ValueNotifier(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  /// Marks the trigger open for the lifetime of the sheet.
  Future<void> _handleTap() async {
    _expanded.value = true;
    try {
      await widget.onTap();
    } finally {
      // The field can be disposed while the sheet is up — a navigation away
      // pops both — and the notifier is gone by then.
      if (mounted) _expanded.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _expanded,
    builder: (context, expanded, _) => widget.builder(context, expanded, _handleTap),
  );
}
