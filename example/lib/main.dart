import 'package:app_select_fields/app_select_fields.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// Regional-indicator flag emoji for a two-letter country code, e.g. `flag('US')` -> 🇺🇸.
String _flag(String countryCode) =>
    String.fromCharCodes(countryCode.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 65));

/// A distinct colour per tag value, used by the multi-select's templates.
const _tagColors = {
  'urgent': Colors.red,
  'follow_up': Colors.orange,
  'waiting': Colors.blueGrey,
  'archived': Colors.green,
};

/// Stands in for a real backend: 500 cities, served 20 at a time, with a
/// simulated network delay and server-side label filtering.
class _FakeCityApi {
  static const pageSize = 20;
  static final _allCities = List.generate(500, (i) => SelectOption(label: 'City - $i', value: i));

  Future<List<SelectOption<int>>> fetchPage({required int page, required String query}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final matches = query.isEmpty
        ? _allCities
        : _allCities.where((c) => c.label.toLowerCase().contains(query.toLowerCase())).toList();
    final start = page * pageSize;
    if (start >= matches.length) return [];
    final end = (start + pageSize).clamp(0, matches.length);
    return matches.sublist(start, end);
  }
}

/// Demo app showing [AppSingleSelect] and [AppMultiSelect] in a form.
class ExampleApp extends StatelessWidget {
  /// Creates the demo app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app_select_fields example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ExampleHomePage(),
    );
  }
}

/// Page demonstrating both select fields side by side.
class ExampleHomePage extends StatefulWidget {
  /// Creates the demo page.
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  static const _countries = [
    SelectOption(label: 'United States', value: 'US'),
    SelectOption(label: 'United Kingdom', value: 'UK'),
    SelectOption(label: 'Canada', value: 'CA'),
    SelectOption(label: 'Australia', value: 'AU'),
    SelectOption(label: 'Bangladesh', value: 'BD'),
  ];

  static const _tags = [
    SelectOption(label: 'Urgent', value: 'urgent'),
    SelectOption(label: 'Follow up', value: 'follow_up'),
    SelectOption(label: 'Waiting', value: 'waiting'),
    SelectOption(label: 'Archived', value: 'archived'),
  ];

  String? _country;
  List<String> _tagValues = [];

  final _cityApi = _FakeCityApi();
  int? _city;
  List<SelectOption<int>> _cityOptions = [];
  int _cityPage = 0;
  String _cityQuery = '';
  bool _cityHasMore = true;
  bool _cityLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadCityPage();
  }

  Future<void> _loadCityPage({bool reset = false}) async {
    // Without this guard, every scroll notification past the load-more
    // threshold re-enters this method — each call reads the same
    // not-yet-incremented `_cityPage` before the previous fetch resolves,
    // so the same page gets re-fetched and re-appended on a loop.
    if (_cityLoadingMore || (!reset && !_cityHasMore)) return;
    setState(() => _cityLoadingMore = true);
    final page = reset ? 0 : _cityPage;
    final results = await _cityApi.fetchPage(page: page, query: _cityQuery);
    if (!mounted) return;
    setState(() {
      _cityOptions = [if (!reset) ..._cityOptions, ...results];
      _cityPage = page + 1;
      _cityHasMore = results.length >= _FakeCityApi.pageSize;
      _cityLoadingMore = false;
    });
  }

  void _onCitySearchChanged(String query) {
    _cityQuery = query;
    _loadCityPage(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('app_select_fields')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSingleSelect<String>(
              label: 'Country (custom decoration, styles & templates)',
              hint: 'Select a country',
              options: _countries,
              value: _country,
              allowClear: true,
              onChanged: (value) => setState(() => _country = value),
              // Overrides the field label's text style.
              inputLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.indigo),
              // Overrides the placeholder's text style.
              hintStyle: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              // Overrides the selected value's text style.
              inputValueStyle: const TextStyle(fontWeight: FontWeight.w600),
              // Tweaks the trigger's resolved InputDecoration directly.
              inputDecorationStyle: (decoration) =>
                  decoration.copyWith(fillColor: Colors.indigo.withValues(alpha: 0.04), prefixIcon: const Icon(Icons.public)),
              // Custom widget for the selected value's display in the trigger.
              selectedInputTemplate: (context, label, value) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(_flag(value), style: const TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(label)],
              ),
              // Custom widget for each row in the option sheet.
              optionTemplate: (context, label, value) => Row(
                children: [
                  Text(_flag(value), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label)),
                  Text(value, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppSingleSelect<int>(
              label: 'City (backend lazy-loaded, virtual scroll)',
              hint: 'Search or scroll for a city',
              options: _cityOptions,
              value: _city,
              allowClear: true,
              hasMore: _cityHasMore,
              loadingMore: _cityLoadingMore,
              onLoadMore: () => _loadCityPage(),
              onSearchChanged: _onCitySearchChanged,
              onChanged: (value) => setState(() => _city = value),
            ),
            const SizedBox(height: 24),
            AppMultiSelect<String>(
              label: 'Tags (custom decoration, styles & templates)',
              hint: 'Select tags',
              options: _tags,
              values: _tagValues,
              onChanged: (values) => setState(() => _tagValues = values),
              // Hides the sheet's "N selected" summary chip.
              displaySelectedCount: false,
              // Overrides the field label's text style.
              inputLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              // Overrides the placeholder's text style.
              hintStyle: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              // Overrides the joined-label text style (used once selection
              // count passes maxSelectedLabel, or when no template is set).
              inputValueStyle: const TextStyle(fontWeight: FontWeight.w600),
              // Tweaks the trigger's resolved InputDecoration directly.
              inputDecorationStyle: (decoration) => decoration.copyWith(fillColor: Colors.teal.withValues(alpha: 0.04)),
              // Custom widget per selected tag, laid out in a Wrap in the
              // trigger — replaces the default comma-joined text.
              selectedInputTemplate: (context, label, value) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (_tagColors[value] ?? Colors.grey).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label, style: TextStyle(fontSize: 12, color: _tagColors[value] ?? Colors.grey)),
              ),
              // Custom widget for each row in the option sheet.
              optionTemplate: (context, label, value) => Row(
                children: [
                  Icon(Icons.circle, size: 10, color: _tagColors[value] ?? Colors.grey),
                  const SizedBox(width: 10),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
