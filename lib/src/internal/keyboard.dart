import 'package:flutter/widgets.dart';

/// Drops focus from whatever input currently holds it and closes the
/// keyboard, so it does not sit over the sheet that is about to open.
void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
