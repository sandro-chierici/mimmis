import 'package:flutter_test/flutter_test.dart';
import 'package:mimmis/features/home/widgets/date_header.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('DateHeader renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DateHeader(
            selectedDate: DateTime(2025, 6, 15),
            onDayTap: () {},
            onMonthTap: () {},
            onYearTap: () {},
          ),
        ),
      ),
    );
    expect(find.byType(DateHeader), findsOneWidget);
  });
}
