## 0.0.2

* Add `noRecordWidget` to both widgets for a custom empty-state message.
* Add `displaySelectedCount` to `AppMultiSelect` (default `true`) to optionally hide the sheet's "N selected" summary chip.
* Add `inputDecorationStyle`, `inputValueStyle`, `hintStyle`, and `inputLabelStyle` to both widgets for direct style overrides, taking precedence over the equivalent `AppSelectStyle` fields.
* Add `selectedInputTemplate` and `optionTemplate` to both widgets, letting callers replace the default `Text` with a fully custom widget for the trigger's selected-value display and each option-sheet row, given that option's `label` and `value`.
* Add `cancelButtonLabel` and `cancelButtonStyle` to both widgets, and `confirmButtonLabel`/`confirmButtonStyle` to `AppMultiSelect`, to override the sheet's action button text and style. (`AppSingleSelect`'s sheet has no confirm button — it closes on tap.)

## 0.0.1

* Initial release: `AppSingleSelect` and `AppMultiSelect` bottom-sheet fields.
