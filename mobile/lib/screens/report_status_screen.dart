import 'package:flutter/material.dart';

class ReportStatusScreen extends StatelessWidget {
  const ReportStatusScreen({super.key, required this.report});

  final Map<String, dynamic> report;

  static const darkGreen = Color(0xFF024B45);
  static const green = Color(0xFF028B6B);
  static const background = Color(0xFFF2FAF7);
  static const border = Color(0xFFD8EBE6);
  static const secondaryText = Color(0xFF64748B);

  static const _activeStatuses = [
    'SUBMITTED',
    'IN_REVIEW',
    'ASSIGNED',
    'RESOLVED',
  ];

  String get _status => (report['status'] ?? 'SUBMITTED').toString().toUpperCase();

  int get _activeIndex {
    if (_status == 'REJECTED') return 3;
    final index = _activeStatuses.indexOf(_status);
    return index < 0 ? 0 : index;
  }

  String get _statusDescription {
    switch (_status) {
      case 'IN_REVIEW':
        return 'A municipal officer is reviewing your report.';
      case 'ASSIGNED':
        return 'The report has been assigned to a response team.';
      case 'RESOLVED':
        return 'The reported issue has been marked as resolved.';
      case 'REJECTED':
        return 'The report was reviewed and could not be accepted.';
      default:
        return 'Your report was received and is waiting for review.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkGreen,
        elevation: 0,
        title: const Text('Report status', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          _ReportHeader(report: report, status: _status),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progress', style: TextStyle(color: darkGreen, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                if (_status == 'REJECTED')
                  const _StatusStep(label: 'Rejected', description: 'This report is closed.', isComplete: true, isCurrent: true, isLast: true, color: Colors.red)
                else
                  ..._activeStatuses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
                    return _StatusStep(
                      label: _displayStatus(label),
                      description: _descriptionFor(label),
                      isComplete: index <= _activeIndex,
                      isCurrent: index == _activeIndex,
                      isLast: index == _activeStatuses.length - 1,
                      color: index <= _activeIndex ? green : secondaryText,
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: darkGreen),
                const SizedBox(width: 10),
                Expanded(child: Text(_statusDescription, style: const TextStyle(color: darkGreen, height: 1.4))),
              ],
            ),
          ),
          if (report['assignedTeam']?.toString().trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            _InfoRow(label: 'Assigned team', value: report['assignedTeam'].toString()),
          ],
        ],
      ),
    );
  }

  String _displayStatus(String value) => value.replaceAll('_', ' ');

  String _descriptionFor(String value) {
    switch (value) {
      case 'IN_REVIEW':
        return 'Municipal review in progress';
      case 'ASSIGNED':
        return 'Response team assigned';
      case 'RESOLVED':
        return 'Issue resolved';
      default:
        return 'Report submitted';
    }
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.report, required this.status});

  final Map<String, dynamic> report;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ReportStatusScreen.darkGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report['issueType']?.toString() ?? 'Waste report', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(report['referenceNumber']?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Text(status.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(report['location']?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({required this.label, required this.description, required this.isComplete, required this.isCurrent, required this.isLast, required this.color});

  final String label;
  final String description;
  final bool isComplete;
  final bool isCurrent;
  final bool isLast;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isComplete ? color : const Color(0xFFE2E4E4),
                  child: isComplete ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: isComplete ? color.withValues(alpha: .35) : ReportStatusScreen.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: isCurrent ? ReportStatusScreen.darkGreen : ReportStatusScreen.secondaryText, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(description, style: const TextStyle(color: ReportStatusScreen.secondaryText, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ReportStatusScreen.border), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Text('$label: ', style: const TextStyle(color: ReportStatusScreen.secondaryText, fontWeight: FontWeight.w700)), Expanded(child: Text(value, style: const TextStyle(color: ReportStatusScreen.darkGreen, fontWeight: FontWeight.w700)))]),
    );
  }
}
