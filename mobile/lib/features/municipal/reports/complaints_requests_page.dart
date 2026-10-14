import 'package:flutter/material.dart';
import '../../../services/waste_report_service.dart';
import '../../../services/report_review.dart';
import '../theme/municipal_colors.dart';

class ComplaintsRequestsPage extends StatefulWidget {
  const ComplaintsRequestsPage({super.key});

  @override
  State<ComplaintsRequestsPage> createState() => _ComplaintsRequestsPageState();
}

class _ComplaintsRequestsPageState extends State<ComplaintsRequestsPage> {
  final _service = WasteReportService();
  late Future<List<Map<String, dynamic>>> _reports;

  @override
  void initState() {
    super.initState();
    _reports = _service.getAdminReports();
  }

  Future<void> _reload() async {
    final next = _service.getAdminReports();
    setState(() => _reports = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        title: const Text('Complaints & Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _reload, tooltip: 'Refresh reports', icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Could not load complaints. ${snapshot.error}', textAlign: TextAlign.center));
          }
          final reports = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _reload,
            color: MunicipalColors.secondaryGreen,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCards(reports),
                const SizedBox(height: 16),
                _buildCategorySection(reports),
                const SizedBox(height: 16),
                _buildResolutionSection(reports),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _showExport(context, reports),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export current report summary'),
                  style: FilledButton.styleFrom(backgroundColor: MunicipalColors.secondaryGreen),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Map<String, dynamic>> reports) {
    final resolved = reports.where((report) => report['status'] == 'RESOLVED').length;
    final inProgress = reports.where((report) => ['IN_REVIEW', 'ASSIGNED'].contains(report['status'])).length;
    final open = reports.where((report) => !['RESOLVED', 'REJECTED'].contains(report['status'])).length;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.65,
      children: [
        _summaryCard('Total reports', reports.length, MunicipalColors.primaryText, MunicipalColors.surface),
        _summaryCard('Resolved', resolved, MunicipalColors.success, MunicipalColors.success.withValues(alpha: .12)),
        _summaryCard('In progress', inProgress, MunicipalColors.info, MunicipalColors.info.withValues(alpha: .12)),
        _summaryCard('Open', open, MunicipalColors.warning, MunicipalColors.warning.withValues(alpha: .12)),
      ],
    );
  }

  Widget _summaryCard(String title, int value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
      ]),
    );
  }

  Widget _buildCategorySection(List<Map<String, dynamic>> reports) {
    final counts = <String, int>{};
    for (final report in reports) {
      final type = report['issueType']?.toString() ?? 'Other Issue';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _section(
      title: 'Reports by category',
      child: sorted.isEmpty
          ? const Text('No reports available.', style: TextStyle(color: MunicipalColors.secondaryText))
          : Column(children: sorted.map((entry) => _bar(entry.key, entry.value, reports.length)).toList()),
    );
  }

  Widget _buildResolutionSection(List<Map<String, dynamic>> reports) {
    final resolved = reports.where((report) => report['status'] == 'RESOLVED').length;
    final rejected = reports.where((report) => report['status'] == 'REJECTED').length;
    final confirmed = reports.where((report) => report['reporterConfirmed'] == true).length;
    final resolutionRate = reports.isEmpty ? 0 : (resolved * 100 / reports.length).round();
    return _section(
      title: 'Resolution performance',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$resolutionRate% resolved', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: MunicipalColors.darkGreen)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: reports.isEmpty ? 0 : resolved / reports.length, color: MunicipalColors.secondaryGreen, backgroundColor: MunicipalColors.border),
        const SizedBox(height: 12),
        Text('$resolved resolved  •  $rejected rejected  •  $confirmed confirmed by reporters', style: const TextStyle(color: MunicipalColors.secondaryText)),
      ]),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: MunicipalColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _bar(String label, int value, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
        Expanded(child: LinearProgressIndicator(value: total == 0 ? 0 : value / total, color: MunicipalColors.secondaryGreen, backgroundColor: MunicipalColors.surface)),
        const SizedBox(width: 8),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }

  void _showExport(BuildContext context, List<Map<String, dynamic>> reports) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report summary'),
        content: SingleChildScrollView(child: Text(buildExportSummary(reports))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}
