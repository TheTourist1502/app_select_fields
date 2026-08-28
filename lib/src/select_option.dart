/// A label + value pair for use with [AppSingleSelect] and [AppMultiSelect].
class SelectOption<T> {
  /// Pairs display text with the value reported back to the caller.
  const SelectOption({required this.label, required this.value});

  /// Human-readable text shown in the list and trigger field.
  final String label;

  /// The underlying value passed to the caller's `onChanged`.
  final T value;
}
