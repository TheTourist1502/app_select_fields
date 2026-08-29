import 'package:flutter/material.dart';

import 'spacing.dart';

/// The inline validation message drawn under a select trigger field, flush
/// with the field's left edge rather than inset under the input text.
class FieldErrorText extends StatelessWidget {
  /// Creates a [FieldErrorText].
  const FieldErrorText({required this.message, super.key, this.excludeSemantics = false, this.style});

  /// The message to show.
  final String message;

  /// Whether to keep the message out of the semantics tree because the
  /// field's own `errorText` already announces it.
  final bool excludeSemantics;

  /// Overrides the message's text style. Defaults to a small caption in
  /// `Theme.of(context).colorScheme.error`.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = Padding(
      padding: const EdgeInsets.only(top: kSelectSpaceXs),
      child: Text(
        message,
        style:
            style ??
            TextStyle(fontSize: 11, height: 13 / 11, color: Theme.of(context).colorScheme.error),
      ),
    );

    return excludeSemantics ? ExcludeSemantics(child: text) : text;
  }
}

/// Collapses `InputDecoration.errorText` to nothing, so the field keeps its
/// red error border and semantics while [FieldErrorText] draws the message.
const TextStyle kHiddenErrorStyle = TextStyle(fontSize: 0, height: 0);
