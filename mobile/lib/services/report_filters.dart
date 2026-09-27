List<Map<String, dynamic>> filterReports(
  List<Map<String, dynamic>> reports, {
    String query = '',
    String status = 'All',
    String priority = 'All',
  }) {
  final searchTerm = query.trim().toLowerCase();
  final normalizedStatus = status.trim().toUpperCase();
  final normalizedPriority = priority.trim().toUpperCase();

  return reports.where((report) {
    final reportStatus = (report['status'] ?? 'SUBMITTED').toString().toUpperCase();
    final reportPriority = (report['priority'] ?? 'MEDIUM').toString().toUpperCase();
    final matchesStatus = normalizedStatus == 'ALL' || reportStatus == normalizedStatus;
    final matchesPriority = normalizedPriority == 'ALL' || reportPriority == normalizedPriority;
    if (!matchesStatus || !matchesPriority) {
      return false;
    }

    if (searchTerm.isEmpty) {
      return true;
    }

    final searchableText = [
      report['issueType'],
      report['location'],
      report['referenceNumber'],
      report['assignedTeam'],
      report['description'],
      report['wasteCategory'],
    ].join(' ').toLowerCase();

    return searchableText.contains(searchTerm);
  }).toList();
}
