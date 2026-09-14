String buildReviewSummary(Map<String, dynamic> report) {
  final referenceNumber = (report['referenceNumber'] ?? 'N/A').toString();
  final issueType = (report['issueType'] ?? 'Unknown issue').toString();
  final location = (report['location'] ?? 'Unknown location').toString();
  final status = (report['status'] ?? 'SUBMITTED').toString().toUpperCase();
  final priority = (report['priority'] ?? 'MEDIUM').toString().toUpperCase();

  return [
    'Reference: $referenceNumber',
    'Issue: $issueType',
    'Location: $location',
    'Status: $status',
    'Priority: $priority',
  ].join('\n');
}

List<Map<String, dynamic>> sortReportsForReview(List<Map<String, dynamic>> reports) {
  final priorityOrder = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};

  final normalized = reports.map((report) {
    final createdAt = report['createdAt']?.toString() ?? '';
    final parsed = DateTime.tryParse(createdAt);
    return {
      ...report,
      '_createdAtMs': parsed?.millisecondsSinceEpoch ?? 0,
      '_priorityRank': priorityOrder[(report['priority'] ?? 'MEDIUM').toString().toUpperCase()] ?? 0,
    };
  }).toList();

  final newestTimestamp = normalized.fold<int>(0, (maxValue, report) {
    final value = report['_createdAtMs'] as int;
    return value > maxValue ? value : maxValue;
  });

  normalized.sort((a, b) {
    final aIsNewest = (a['_createdAtMs'] as int) == newestTimestamp;
    final bIsNewest = (b['_createdAtMs'] as int) == newestTimestamp;

    if (aIsNewest && !bIsNewest) return -1;
    if (!aIsNewest && bIsNewest) return 1;

    final priorityCompare = (b['_priorityRank'] as int).compareTo(a['_priorityRank'] as int);
    if (priorityCompare != 0) return priorityCompare;
    return (b['_createdAtMs'] as int).compareTo(a['_createdAtMs'] as int);
  });

  return normalized.map((report) => report..removeWhere((key, value) => key.startsWith('_'))).toList();
}

String buildVerificationChecklist(Map<String, dynamic> report) {
  final checks = [
    'Incident details match the report.',
    'Location is accurate and traceable.',
    'Photo / evidence is attached if applicable.',
    'Priority is assigned appropriately.',
    'Assigned team is confirmed for action.',
  ];

  final issueType = (report['issueType'] ?? 'Issue').toString();
  final location = (report['location'] ?? 'Location').toString();
  final referenceNumber = (report['referenceNumber'] ?? 'N/A').toString();

  return [
    'Verification checklist for $referenceNumber',
    'Issue: $issueType',
    'Location: $location',
    ...checks.map((check) => '- [ ] $check'),
  ].join('\n');
}

String? validateReportTransition({
  required String currentStatus,
  required String nextStatus,
  required String assignedTeam,
  String? reviewNotes,
}) {
  final normalizedCurrent = currentStatus.toUpperCase();
  final normalizedNext = nextStatus.toUpperCase();

  final invalidTransitions = {
    'SUBMITTED': {'RESOLVED'},
    'IN_REVIEW': {'SUBMITTED'},
    'ASSIGNED': {'SUBMITTED'},
    'RESOLVED': {'IN_REVIEW', 'SUBMITTED'},
    'REJECTED': {'IN_REVIEW', 'SUBMITTED', 'ASSIGNED', 'RESOLVED'},
  };

  if (invalidTransitions[normalizedCurrent]?.contains(normalizedNext) ?? false) {
    return 'Status cannot move from $normalizedCurrent to $normalizedNext.';
  }

  if ((normalizedNext == 'ASSIGNED' || normalizedNext == 'IN_REVIEW') && assignedTeam.trim().isEmpty) {
    return 'An assigned team is required before moving to $normalizedNext.';
  }

  if (normalizedNext == 'REJECTED' && (reviewNotes ?? '').trim().isEmpty) {
    return 'review notes are required before rejecting a report.';
  }

  return null;
}

String buildExportSummary(List<Map<String, dynamic>> reports) {
  if (reports.isEmpty) return 'No reports available for export.';

  final lines = <String>['EcoMate Waste Report Summary', ''];
  for (final report in sortReportsForReview(reports)) {
    final reference = (report['referenceNumber'] ?? 'N/A').toString();
    final issue = (report['issueType'] ?? 'Unknown issue').toString();
    final location = (report['location'] ?? 'Unknown location').toString();
    final status = (report['status'] ?? 'SUBMITTED').toString().toUpperCase();
    final priority = (report['priority'] ?? 'MEDIUM').toString().toUpperCase();
    lines.add('- $reference | $issue | $location | $status | $priority');
  }

  return lines.join('\n');
}

