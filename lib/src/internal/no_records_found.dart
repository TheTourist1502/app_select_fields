import 'package:flutter/material.dart';

/// Default empty-state shown in place of the option list when there are no
/// options to render. Overridable per-field via `noRecordWidget`.
///
/// Fills the sheet's scrollable body (an `Expanded`, so already
/// height-bounded) and centers within it, rather than just centering its own
/// tight-height content.
class NoRecordsFound extends StatelessWidget {
  /// Creates the default "No Records Found !" message.
  const NoRecordsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No Records Found !', style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
