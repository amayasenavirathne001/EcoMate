// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/report_issue_screen.dart';

void main() {
  testWidgets('selecting an issue type opens report details', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReportIssueScreen(),
      ),
    );

    expect(find.text('Illegal Dumping'), findsOneWidget);

    await tester.tap(find.text('Overflowing Bin'));
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Report Details'), findsOneWidget);
    expect(find.text('Issue: Overflowing Bin'), findsOneWidget);
  });
}
