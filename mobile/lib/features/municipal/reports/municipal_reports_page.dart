import 'package:flutter/material.dart';
import '../../../services/waste_report_service.dart';
import '../theme/municipal_colors.dart';
import 'report_location_map_page.dart';

class MunicipalReportsPage extends StatefulWidget {
  const MunicipalReportsPage({super.key});

  @override
  State<MunicipalReportsPage> createState() => _MunicipalReportsPageState();
}

class _MunicipalReportsPageState extends State<MunicipalReportsPage> {
  final _service = WasteReportService();
  late Future<List<Map<String, dynamic>>> _reports;
  String _filter = 'All';
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _reports = _service.getAdminReports();
  }

  Future<void> _reload() async {
    if (_isReloading) return; // Prevent multiple simultaneous requests
    _isReloading = true;
    try {
      final reports = _service.getAdminReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
      });
      await reports; // Wait for the reports to complete loading
    } finally {
      if (mounted) {
        _isReloading = false;
      }
    }
  }

  Future<void> _editReport(Map<String, dynamic> report) async {
    var status = report['status']?.toString() ?? 'SUBMITTED';
    var priority = report['priority']?.toString() ?? 'MEDIUM';
    var team = report['assignedTeam']?.toString() ?? '';
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(report['issueType']?.toString() ?? 'Report', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const ['SUBMITTED', 'IN_REVIEW', 'ASSIGNED', 'RESOLVED', 'REJECTED'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setSheetState(() => status = value ?? status),
            ),
            DropdownButtonFormField<String>(
              initialValue: priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const ['LOW', 'MEDIUM', 'HIGH'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setSheetState(() => priority = value ?? priority),
            ),
            TextFormField(initialValue: team, decoration: const InputDecoration(labelText: 'Assigned team'), onChanged: (value) => team = value),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context, {'status': status, 'priority': priority, 'assignedTeam': team}), child: const Text('Save update'))),
          ]),
        );
      }),
    );
    if (result == null || !mounted) return;
    try {
      final updated = await _service.updateAdminReport(
        id: (report['id'] as num).toInt(),
        status: result['status']!,
        priority: result['priority']!,
        assignedTeam: result['assignedTeam']!,
      );
      final currentReports = await _reports;
      final updatedReports = currentReports.map((currentReport) {
        return currentReport['id'] == updated['id'] ? updated : currentReport;
      }).toList();
      if (mounted) setState(() => _reports = Future.value(updatedReports));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report updated successfully')));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $error')));
    }
  }

  void _viewLocation(Map<String, dynamic> report) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportLocationMapPage(report: report)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: MunicipalColors.border,
            height: 1,
          ),
        ),
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () { _reload(); }, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: MunicipalColors.error)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            );
          }
          final all = snapshot.data ?? [];
          final reports = _filter == 'All' ? all : all.where((item) => item['status'] == _filter).toList();
          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: Row(children: [
              _summary('Open', all.where((item) => item['status'] != 'RESOLVED').length, MunicipalColors.warning),
              _summary('Review', all.where((item) => item['status'] == 'IN_REVIEW').length, MunicipalColors.info),
              _summary('Resolved', all.where((item) => item['status'] == 'RESOLVED').length, MunicipalColors.success),
            ])),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All', 'SUBMITTED', 'IN_REVIEW', 'ASSIGNED', 'RESOLVED', 'REJECTED',
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(item.replaceAll('_', ' ')),
                    selected: _filter == item,
                    onSelected: (_) => setState(() => _filter = item),
                  ),
                )).toList(),
              ),
            ),
            Expanded(child: reports.isEmpty ? const Center(child: Text('No reports in this filter.')) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: reports.length, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, index) => _ReportTile(report: reports[index], onEdit: () => _editReport(reports[index]), onViewLocation: () => _viewLocation(reports[index])))),
          ]);
        },
      ),
    );
  }

  Widget _summary(String label, int value, Color color) => Expanded(child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 11))])));
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.onEdit, required this.onViewLocation});
  final Map<String, dynamic> report;
  final VoidCallback onEdit;
  final VoidCallback onViewLocation;

  @override
  Widget build(BuildContext context) {
    final status = report['status']?.toString() ?? 'SUBMITTED';
    final priority = report['priority']?.toString() ?? 'MEDIUM';
    return ListTile(
      onTap: onEdit,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: MunicipalColors.border)),
      leading: CircleAvatar(backgroundColor: MunicipalColors.surface, child: Icon(Icons.report_problem_outlined, color: status == 'RESOLVED' ? MunicipalColors.success : MunicipalColors.secondaryGreen)),
      title: Text(report['issueType']?.toString() ?? 'Waste report', style: const TextStyle(fontWeight: FontWeight.w700, color: MunicipalColors.primaryText)),
      subtitle: Text('${report['referenceNumber']}\n${report['location']}\nPriority: $priority', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MunicipalColors.secondaryText, height: 1.4)),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(status.replaceAll('_', ' '), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: MunicipalColors.secondaryGreen)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onViewLocation,
                tooltip: 'View location on map',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.location_on_outlined,
                  size: 19,
                  color: report['latitude'] != null && report['longitude'] != null ? MunicipalColors.secondaryGreen : MunicipalColors.mutedText,
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit report',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 18, color: MunicipalColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
