## 0.0.4

* Fix `AppSingleSelect` showing the plain hint (instead of a visible value) when a pre-set `value` isn't in the currently loaded `options` page — e.g. an edit form backed by lazy pagination whose matching page hasn't arrived yet.
* Add `errorText` to `AppMultiSelect` to match `AppSingleSelect`, letting callers show a validation message without a `Form`/`validator`.
* Document that `options` (and `values` on `AppMultiSelect`) must be a new list instance on change, not the same list mutated in place, since cached display state only recomputes on an identity check.
* Fix a `.gitignore` typo (`example/andriod/` → `example/android/`) that left the real Android platform folder untracked-but-not-ignored.
* Add `errorTextStyle` to both widgets and to `AppSelectStyle`, to override the validation message's text style — the widget-level one wins when both are set.

## 0.0.3 and 0.0.2 

* Add `noRecordWidget` to both widgets for a custom empty-state message.
* Add `displaySelectedCount` to `AppMultiSelect` (default `true`) to optionally hide the sheet's "N selected" summary chip.
* Add `inputDecorationStyle`, `inputValueStyle`, `hintStyle`, and `inputLabelStyle` to both widgets and to `AppSelectStyle`, for direct style overrides — the widget-level one wins when both are set. Renames `AppSelectStyle.labelStyle` to `inputLabelStyle` and `AppSelectStyle.textStyle` to `inputValueStyle` to match.
* Add `selectedInputTemplate` and `optionTemplate` to both widgets, letting callers replace the default `Text` with a fully custom widget for the trigger's selected-value display and each option-sheet row, given that option's `label` and `value`.
* Add `cancelButtonLabel` and `cancelButtonStyle` to both widgets (the latter also on `AppSelectStyle`), and `confirmButtonLabel`/`confirmButtonStyle` to `AppMultiSelect`, to override the sheet's action button text and style. (`AppSingleSelect`'s sheet has no confirm button — it closes on tap.)

## 0.0.1

* Initial release: `AppSingleSelect` and `AppMultiSelect` bottom-sheet fields.
