import 'package:app_select_fields/app_select_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = [
    SelectOption(label: 'Apple', value: 'apple'),
    SelectOption(label: 'Banana', value: 'banana'),
  ];

  Widget host({List<String> values = const [], ValueChanged<List<String>>? onChanged}) => MaterialApp(
    home: Scaffold(
      body: AppMultiSelect<String>(
        label: 'Fruits',
        options: options,
        values: values,
        onChanged: onChanged,
      ),
    ),
  );

  testWidgets('shows the joined labels of the selected values', (tester) async {
    await tester.pumpWidget(host(values: const ['apple', 'banana']));
    expect(find.text('Apple, Banana'), findsOneWidget);
  });

  testWidgets('picking options in the sheet and confirming reports the values back', (tester) async {
    List<String>? picked;
    await tester.pumpWidget(host(onChanged: (v) => picked = v));

    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple'));
    await tester.tap(find.text('Banana'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(picked, containsAll(<String>['apple', 'banana']));
    expect(picked, hasLength(2));
  });
}
