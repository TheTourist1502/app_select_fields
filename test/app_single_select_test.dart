import 'package:app_select_fields/app_select_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = [
    SelectOption(label: 'Apple', value: 'apple'),
    SelectOption(label: 'Banana', value: 'banana'),
  ];

  Widget host({String? value, ValueChanged<String?>? onChanged}) => MaterialApp(
    home: Scaffold(
      body: AppSingleSelect<String>(
        label: 'Fruit',
        options: options,
        value: value,
        onChanged: onChanged,
      ),
    ),
  );

  testWidgets('shows hint when nothing selected, selected label when a value is set', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('Fruit'), findsOneWidget);

    await tester.pumpWidget(host(value: 'banana'));
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('tapping the field opens the sheet and picking an option reports it back', (tester) async {
    String? picked;
    await tester.pumpWidget(host(onChanged: (v) => picked = v));

    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(picked, 'banana');
    expect(find.text('Apple'), findsNothing);
  });
}
