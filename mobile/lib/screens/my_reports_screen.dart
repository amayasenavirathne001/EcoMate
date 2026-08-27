import 'package:flutter/material.dart';

import '../services/waste_report_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  static const darkGreen = Color(0xFF024B45);
  static const background = Color(0xFFF2FAF7);
  static const border = Color(0xFFD8EBE6);
  static const secondaryText = Color(0xFF64748B);

  final _service = WasteReportService();
  late Future<List<Map<String, dynamic>>> _reports;

  @override
  void initState() {
    super.initState();
    _reports = _service.getMyReports();
  }

  void _reload() => setState(() => _reports = _service.getMyReports());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkGreen,
        elevation: 0,
        title: const Text('My Reports', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: darkGreen));
          }
          if (snapshot.hasError) {
            return _MessageState(message: 'Could not load your reports.', onRetry: _reload);
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const _MessageState(message: 'You have not submitted any reports yet.');
          }
          return RefreshIndicator(
            color: darkGreen,
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _ReportCard(report: reports[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final status = (report['status'] ?? 'SUBMITTED').toString();
    final statusColor = status == 'RESOLVED' ? const Color(0xFF028B6B) : const Color(0xFFFFC857);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _MyReportsScreenState.border), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text((report['issueType'] ?? 'Waste issue').toString(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text((report['referenceNumber'] ?? '').toString(), style: const TextStyle(color: _MyReportsScreenState.secondaryText, fontSize: 12)),
          const SizedBox(height: 5),
          Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: _MyReportsScreenState.secondaryText), const SizedBox(width: 4), Expanded(child: Text((report['location'] ?? '').toString(), style: const TextStyle(color: _MyReportsScreenState.secondaryText, fontSize: 12)))]),
          const SizedBox(height: 5),
          Text((report['createdAt'] ?? '').toString().replaceFirst('T', ' '), style: const TextStyle(color: _MyReportsScreenState.secondaryText, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: const TextStyle(color: _MyReportsScreenState.secondaryText)),
        if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
