import 'package:flutter/foundation.dart';

import '../select_option.dart';

/// Snapshot of a select sheet's options plus pagination flags.
///
/// Pushed into an already-open sheet via a `ValueNotifier` so lazy-loaded
/// pages reach it without the sheet depending on any state-management
/// package.
@immutable
class LazySelectState<T> {
  /// Captures the current options and their pagination flags.
  const LazySelectState({required this.options, required this.hasMore, required this.loadingMore});

  /// Options currently available to render.
  final List<SelectOption<T>> options;

  /// Whether another page exists server-side.
  final bool hasMore;

  /// Whether a pagination request is in flight.
  final bool loadingMore;
}
