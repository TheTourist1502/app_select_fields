import 'package:flutter/material.dart';

/// The search box at the top of a select sheet: magnify prefix, rounded
/// border, and a clear ("x") button that appears once the field holds text.
///
/// Self-contained (no external icon package) so the select widgets add no
/// dependency beyond the Flutter SDK.
class SelectSearchField extends StatelessWidget {
  /// Creates a [SelectSearchField].
  const SelectSearchField({
    required this.controller,
    required this.onChanged,
    required this.hintText,
    required this.borderRadius,
    super.key,
    this.loading = false,
  });

  /// Backing controller for the field's text.
  final TextEditingController controller;

  /// Called on every keystroke, and with `''` when cleared.
  final ValueChanged<String> onChanged;

  /// Placeholder text.
  final String hintText;

  /// Corner radius matching the sheet's other controls.
  final double borderRadius;

  /// Whether a server-side search for the current text is still running;
  /// shows a spinner in place of the clear button.
  final bool loading;

  void _handleClear() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) => value.text.isEmpty ? const SizedBox.shrink() : child!,
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.onSurfaceVariant),
                  ),
                )
              : IconButton(
                  onPressed: _handleClear,
                  icon: Icon(Icons.close, color: colors.onSurfaceVariant, size: 18),
                ),
        ),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
