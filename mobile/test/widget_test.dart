// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/report_issue_screen.dart';
import 'package:mobile/services/report_filters.dart';
import 'package:mobile/services/report_review.dart';

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

  test('report filters match status and text search', () {
    final reports = [
      {'id': 1, 'issueType': 'Illegal Dumping', 'location': 'Lake Road', 'referenceNumber': 'RPT-1001', 'status': 'SUBMITTED', 'createdAt': '2025-01-03T10:00:00'},
      {'id': 2, 'issueType': 'Overflowing Bin', 'location': 'Market Square', 'referenceNumber': 'RPT-2002', 'status': 'RESOLVED', 'createdAt': '2025-01-05T10:00:00'},
      {'id': 3, 'issueType': 'Damaged Bin', 'location': 'Lake Road', 'referenceNumber': 'RPT-3003', 'status': 'IN_REVIEW', 'createdAt': '2025-01-04T10:00:00'},
    ];

    final filtered = filterReports(reports, query: 'lake', status: 'All');
    expect(filtered.map((report) => report['id']), [1, 3]);

    final resolved = filterReports(reports, query: '', status: 'RESOLVED');
    expect(resolved.single['id'], 2);
  });

  test('review summary includes critical report details for verification', () {
    final summary = buildReviewSummary({
      'referenceNumber': 'RPT-1001',
      'issueType': 'Illegal Dumping',
      'location': 'Lake Road',
      'status': 'SUBMITTED',
      'priority': 'HIGH',
    });

    expect(summary, contains('RPT-1001'));
    expect(summary, contains('Illegal Dumping'));
    expect(summary, contains('Lake Road'));
    expect(summary, contains('HIGH'));
  });

  test('sorting prioritizes newest and higher priority reports', () {
    final reports = [
      {'id': 1, 'priority': 'LOW', 'createdAt': '2025-01-03T10:00:00'},
      {'id': 2, 'priority': 'HIGH', 'createdAt': '2025-01-01T10:00:00'},
      {'id': 3, 'priority': 'MEDIUM', 'createdAt': '2025-01-05T10:00:00'},
    ];

    final sorted = sortReportsForReview(reports);
    expect(sorted.map((report) => report['id']), [3, 2, 1]);
  });

  test('validation blocks invalid status transitions', () {
    expect(
      validateReportTransition(
        currentStatus: 'SUBMITTED',
        nextStatus: 'ASSIGNED',
        assignedTeam: '',
      ),
      contains('assigned team'),
    );

    expect(
      validateReportTransition(
        currentStatus: 'SUBMITTED',
        nextStatus: 'REJECTED',
        assignedTeam: 'Waste Team A',
        reviewNotes: '',
      ),
      contains('review notes'),
    );
  });
}
