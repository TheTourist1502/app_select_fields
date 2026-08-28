import 'package:app_select_fields/app_select_fields.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

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
              label: 'Country (custom label/hint/value style)',
              hint: 'Select a country',
              options: _countries,
              value: _country,
              allowClear: true,
              onChanged: (value) => setState(() => _country = value),
              style: const AppSelectStyle(
                labelStyle: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.indigo),
                hintStyle: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                textStyle: TextStyle(fontWeight: FontWeight.w600),
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
              label: 'Tags (multi select)',
              hint: 'Select tags',
              options: _tags,
              values: _tagValues,
              onChanged: (values) => setState(() => _tagValues = values),
            ),
          ],
        ),
      ),
    );
  }
}
