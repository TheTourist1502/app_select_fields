# app_select_fields

[![pub package](https://img.shields.io/pub/v/app_select_fields.svg)](https://pub.dev/packages/app_select_fields)
[![pub points](https://img.shields.io/pub/points/app_select_fields)](https://pub.dev/packages/app_select_fields/score)
[![pub likes](https://img.shields.io/pub/likes/app_select_fields)](https://pub.dev/packages/app_select_fields/score)
[![CI](https://github.com/TheTourist1502/app_select_fields/actions/workflows/ci.yml/badge.svg)](https://github.com/TheTourist1502/app_select_fields/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Flutter **dropdown / select field** package: labelled, form-integrated
single-select and multi-select inputs that open a draggable, root-level
**bottom sheet picker** with built-in search, pagination and server-search
hooks. Styled from the ambient **Material 3** `Theme` by default — no
configuration required, and no extra dependencies.

Useful as a Material dropdown alternative, multi-select chip picker, tag
selector, or searchable option list in any `Form`.

<p align="center">
  <img src="https://raw.githubusercontent.com/TheTourist1502/app_select_fields/master/doc/app-select-fields.png" width="240" alt="Both fields closed" />
  <img src="https://raw.githubusercontent.com/TheTourist1502/app_select_fields/master/doc/app-single-select.png" width="240" alt="AppSingleSelect sheet open" />
  <img src="https://raw.githubusercontent.com/TheTourist1502/app_select_fields/master/doc/app-multi-select.png" width="240" alt="AppMultiSelect sheet open" />
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/TheTourist1502/app_select_fields/master/doc/demo.gif" width="280" alt="Picking options in the bottom sheet" />
</p>

## Features

- `AppSingleSelect<T>` — radio-style picker, optional "Clear" action.
- `AppMultiSelect<T>` — checkbox picker with a live selection-count chip.
- Built-in search box, with optional debounced server-search callback.
- Optional lazy pagination (`onLoadMore`, `hasMore`, `loadingMore`).
- Works inside a `Form` via the standard `validator` API.
- `AppSelectStyle` to override radii, animation timing, text styles and the
  built-in English copy (search hint, button labels, "N selected").

## Usage

```dart
import 'package:app_select_fields/app_select_fields.dart';

AppSingleSelect<String>(
  label: 'Country',
  hint: 'Select a country',
  options: const [
    SelectOption(label: 'United States', value: 'US'),
    SelectOption(label: 'United Kingdom', value: 'UK'),
  ],
  value: selectedCountry,
  onChanged: (value) => setState(() => selectedCountry = value),
);

AppMultiSelect<String>(
  label: 'Tags',
  options: const [
    SelectOption(label: 'Urgent', value: 'urgent'),
    SelectOption(label: 'Follow up', value: 'follow_up'),
  ],
  values: selectedTags,
  onChanged: (values) => setState(() => selectedTags = values),
);
```

### Backend lazy loading / virtual scroll

For large or server-backed option lists, pass `onLoadMore` (infinite scroll,
fired near the end of the list) and/or `onSearchChanged` (debounced
server-search). The sheet's list is already a virtualized `ListView.builder`,
so only visible rows are built regardless of list size — you just feed it
pages as they arrive:

```dart
AppSingleSelect<String>(
  label: 'City',
  options: _cityOptions, // grows as pages arrive
  value: _city,
  hasMore: _cityHasMore,
  loadingMore: _cityLoadingMore,
  onLoadMore: () => _fetchNextPage(), // append results, update hasMore
  onSearchChanged: (query) => _fetchFirstPage(query), // replace options
  onChanged: (value) => setState(() => _city = value),
);
```

See `example/` for a runnable demo of both widgets, including a fake
paginated "backend" for `AppSingleSelect` and a custom `AppSelectStyle`.

### Custom decoration, styles & templates

Every field on both widgets below is optional. `inputDecorationStyle` gets
the package's fully-resolved `InputDecoration` to tweak or replace;
`inputValueStyle`/`hintStyle`/`inputLabelStyle` override individual text
styles (each takes precedence over the equivalent `AppSelectStyle` field);
`selectedInputTemplate` and `optionTemplate` replace the default `Text` with
a custom widget, both called with the option's `label` and `value`:

```dart
AppSingleSelect<String>(
  label: 'Country',
  options: _countries, // SelectOption<String>, value is a country code
  value: selectedCountry,
  onChanged: (value) => setState(() => selectedCountry = value),
  inputLabelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
  hintStyle: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
  inputValueStyle: const TextStyle(fontWeight: FontWeight.w600),
  inputDecorationStyle: (decoration) => decoration.copyWith(prefixIcon: const Icon(Icons.public)),
  // Trigger field's selected-value display:
  selectedInputTemplate: (context, label, value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [Text(flagEmoji(value)), const SizedBox(width: 8), Text(label)],
  ),
  // Each row in the option sheet:
  optionTemplate: (context, label, value) => Row(
    children: [Text(flagEmoji(value)), const SizedBox(width: 12), Text(label)],
  ),
  // The sheet's Cancel button — the only action button on a single-select
  // sheet, since tapping an option confirms immediately:
  cancelButtonLabel: 'Dismiss',
  cancelButtonStyle: OutlinedButton.styleFrom(foregroundColor: Colors.indigo),
);
```

`AppMultiSelect` supports the same six properties, plus
`displaySelectedCount` (default `true`) to hide the sheet's "N selected"
summary chip. Its `selectedInputTemplate` is called once per selected
option and the results are laid out in a `Wrap` in the trigger, in place of
the default comma-joined text — falling back to that text once the
selection count passes `maxSelectedLabel`:

```dart
AppMultiSelect<String>(
  label: 'Tags',
  options: _tags,
  values: selectedTags,
  onChanged: (values) => setState(() => selectedTags = values),
  displaySelectedCount: false, // hide the "N selected" chip in the sheet
  selectedInputTemplate: (context, label, value) => Chip(label: Text(label)), // one per selected tag
  optionTemplate: (context, label, value) => Row(
    children: [Icon(Icons.circle, size: 10, color: tagColor(value)), const SizedBox(width: 10), Text(label)],
  ),
  // The sheet's Cancel / confirm (OK) buttons:
  cancelButtonLabel: 'Dismiss',
  cancelButtonStyle: FilledButton.styleFrom(backgroundColor: Colors.grey.shade200),
  confirmButtonLabel: 'Apply',
  confirmButtonStyle: FilledButton.styleFrom(backgroundColor: Colors.teal),
);
```

## AppSingleSelect&lt;T&gt; properties

| Property | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | required | Text shown above the field. |
| `options` | `List<SelectOption<T>>` | required | Options offered in the sheet. |
| `hint` | `String?` | `null` | Placeholder shown while nothing is selected. |
| `value` | `T?` | `null` | Currently selected value; the field is fully controlled by the caller. |
| `onChanged` | `ValueChanged<T?>?` | `null` | Called with the newly picked value when the sheet closes. |
| `enabled` | `bool` | `true` | Whether the field accepts interaction. |
| `allowClear` | `bool` | `false` | Shows a Clear button beside Cancel while `value` is non-null; calls `onChanged(null)`. |
| `loading` | `bool` | `false` | Shows a spinner in place of the chevron and disables the field. |
| `required` | `bool` | `false` | Adds a red `*` to the label. Purely visual — pair with `errorText`/`validator`. |
| `errorText` | `String?` | `null` | Caller-driven validation message; takes precedence over `validator`. |
| `validator` | `String? Function(T?)?` | `null` | Form validator run against the selected value. |
| `hasMore` | `bool` | `false` | Whether a further page of `options` exists server-side. Ignored unless `onLoadMore` is set. |
| `loadingMore` | `bool` | `false` | Shows a loading row while the next page is fetched. Ignored unless `onLoadMore` is set. |
| `onLoadMore` | `VoidCallback?` | `null` | Fires when the sheet's list is scrolled past ~85%. Enables lazy pagination. |
| `onSearchChanged` | `ValueChanged<String>?` | `null` | Debounced (~400ms) server-search callback; disables local filtering when set. |
| `displayLabel` | `bool` | `true` | Whether `label` renders above the field, e.g. when a surrounding layout already names it. |
| `style` | `AppSelectStyle` | `AppSelectStyle()` | Visual/copy overrides — see below. |
| `noRecordWidget` | `Widget?` | `null` | Shown centered in the sheet's list area when `options` is empty. Defaults to a "No Records Found !" message. |
| `inputDecorationStyle` | `InputDecoration Function(InputDecoration)?` | `null` | Customizes the trigger's resolved `InputDecoration`. |
| `inputValueStyle` | `TextStyle?` | `null` | Overrides the selected value's text style. Takes precedence over `AppSelectStyle.textStyle`. |
| `hintStyle` | `TextStyle?` | `null` | Overrides the placeholder's text style. Takes precedence over `AppSelectStyle.hintStyle`. |
| `inputLabelStyle` | `TextStyle?` | `null` | Overrides the field label's text style. Takes precedence over `AppSelectStyle.labelStyle`. |
| `selectedInputTemplate` | `Widget Function(BuildContext, String label, T value)?` | `null` | Builds the trigger's selected-value display in place of the default `Text`. |
| `optionTemplate` | `Widget Function(BuildContext, String label, T value)?` | `null` | Builds each row's content in the option sheet in place of the default `Text`. |
| `cancelButtonLabel` | `String?` | `null` | Overrides the sheet's Cancel button label. Takes precedence over `AppSelectStyle.cancelLabel`. |
| `cancelButtonStyle` | `ButtonStyle?` | `null` | Overrides the sheet's Cancel button style. |

## AppMultiSelect&lt;T&gt; properties

| Property | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | required | Text shown above the field. |
| `options` | `List<SelectOption<T>>` | required | Options offered in the sheet. |
| `hint` | `String?` | `null` | Placeholder shown while nothing is selected. |
| `values` | `List<T>` | `[]` | Currently selected values; the field is fully controlled by the caller. |
| `onChanged` | `ValueChanged<List<T>>?` | `null` | Called with the confirmed values when the sheet's OK button is tapped. |
| `maxSelectedLabel` | `int?` | `null` | Once the selected count exceeds this, the trigger shows "N selected" instead of the joined labels. |
| `enabled` | `bool` | `true` | Whether the field accepts interaction. |
| `validator` | `String? Function(List<T>?)?` | `null` | Form validator run against the selected values. |
| `style` | `AppSelectStyle` | `AppSelectStyle()` | Visual/copy overrides — see below. |
| `noRecordWidget` | `Widget?` | `null` | Shown centered in the sheet's list area when `options` is empty. Defaults to a "No Records Found !" message. |
| `displaySelectedCount` | `bool` | `true` | Whether the sheet's "N selected" summary chip shows above the option list. |
| `inputDecorationStyle` | `InputDecoration Function(InputDecoration)?` | `null` | Customizes the trigger's resolved `InputDecoration`. |
| `inputValueStyle` | `TextStyle?` | `null` | Overrides the selected values' text style. Takes precedence over `AppSelectStyle.textStyle`. |
| `hintStyle` | `TextStyle?` | `null` | Overrides the placeholder's text style. Takes precedence over `AppSelectStyle.hintStyle`. |
| `inputLabelStyle` | `TextStyle?` | `null` | Overrides the field label's text style. Takes precedence over `AppSelectStyle.labelStyle`. |
| `selectedInputTemplate` | `Widget Function(BuildContext, String label, T value)?` | `null` | Builds each selected option's display, laid out in a `Wrap` in the trigger, in place of the default joined text. Falls back to the joined text once the count passes `maxSelectedLabel`. |
| `optionTemplate` | `Widget Function(BuildContext, String label, T value)?` | `null` | Builds each row's content in the option sheet in place of the default `Text`. |
| `cancelButtonLabel` | `String?` | `null` | Overrides the sheet's Cancel button label. Takes precedence over `AppSelectStyle.cancelLabel`. |
| `cancelButtonStyle` | `ButtonStyle?` | `null` | Overrides the sheet's Cancel button style. |
| `confirmButtonLabel` | `String?` | `null` | Overrides the sheet's confirm (OK) button label. Takes precedence over `AppSelectStyle.okLabel`. |
| `confirmButtonStyle` | `ButtonStyle?` | `null` | Overrides the sheet's confirm (OK) button style. |

## SelectOption&lt;T&gt;

| Property | Type | Description |
|---|---|---|
| `label` | `String` | Human-readable text shown in the list and trigger field. |
| `value` | `T` | The underlying value reported back via `onChanged`. |

## AppSelectStyle

Every field is optional and falls back to a Material 3 default or an English string.

| Property | Type | Default | Description |
|---|---|---|---|
| `borderRadius` | `double` | `12` | Corner radius of the trigger field's border. |
| `sheetBorderRadius` | `double` | `20` | Corner radius of the sheet's top corners. |
| `chevronAnimationDuration` | `Duration` | `150ms` | How long the trigger's chevron takes to flip. Skipped when reduce-motion is on. |
| `checkAnimationDuration` | `Duration` | `180ms` | How long a radio dot / checkbox takes to animate. Skipped when reduce-motion is on. |
| `labelStyle` | `TextStyle?` | `textTheme.labelMedium` | Overrides the caption above the field. |
| `hintStyle` | `TextStyle?` | `textTheme.bodyMedium` | Overrides the placeholder text style. |
| `textStyle` | `TextStyle?` | `textTheme.bodyMedium` | Overrides the selected value's text style. |
| `searchHint` | `String` | `'Search'` | Placeholder for the sheet's search field. |
| `cancelLabel` | `String` | `'Cancel'` | Label of the button that closes the sheet without changes. |
| `clearLabel` | `String` | `'Clear'` | Label of the button that clears the current selection. |
| `okLabel` | `String` | `'OK'` | Label of the button that confirms a multi-select's choices. |
| `selectedCountLabel` | `String Function(int)?` | `'$count selected'` | Builds the "N selected" summary text. |

```dart
AppSingleSelect<String>(
  label: 'Country',
  options: _countries,
  value: selectedCountry,
  onChanged: (value) => setState(() => selectedCountry = value),
  style: const AppSelectStyle(
    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
    hintStyle: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
    textStyle: TextStyle(fontWeight: FontWeight.w600), // selected value's style
  ),
);
```

## Author

Maintained by [@TheTourist1502](https://github.com/TheTourist1502).
