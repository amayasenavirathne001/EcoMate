import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';
import 'illegal_dumping_reports_page.dart';
import 'waste_collection_page.dart';
import 'recycling_page.dart';
import 'complaints_requests_page.dart';
import 'municipal_operations_page.dart';

class MunicipalReportsPage extends StatelessWidget {
  const MunicipalReportsPage({super.key});

  @override
  State<MunicipalReportsPage> createState() => _MunicipalReportsPageState();
}

class _MunicipalReportsPageState extends State<MunicipalReportsPage> {
  final _service = WasteReportService();
  late Future<List<Map<String, dynamic>>> _reports;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _reports = _service.getAdminReports();
  }

  void _reload() => setState(() => _reports = _service.getAdminReports());

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
      await _service.updateAdminReport(id: (report['id'] as num).toInt(), status: result['status']!, priority: result['priority']!, assignedTeam: result['assignedTeam']!);
      _reload();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context: context,
            title: 'Illegal Dumping',
            subtitle: 'View and manage illegal dumping reports',
            color: MunicipalColors.darkGreen,
            icon: Icons.delete_outline,
            page: const IllegalDumpingReportsPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Waste Collection',
            subtitle: 'Collection requests and performance',
            color: MunicipalColors.secondaryGreen,
            icon: Icons.local_shipping_outlined,
            page: const WasteCollectionPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Recycling',
            subtitle: 'Recycled quantities and materials',
            color: MunicipalColors.info,
            icon: Icons.recycling_outlined,
            page: const RecyclingPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Complaints & Requests',
            subtitle: 'Manage citizen complaints and requests',
            color: MunicipalColors.warning,
            icon: Icons.assignment_outlined,
            page: const ComplaintsRequestsPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Municipal Operations',
            subtitle: 'Overall jobs, active vehicles, driver stats',
            color: MunicipalColors.success,
            icon: Icons.bar_chart_outlined,
            page: const MunicipalOperationsPage(),
          ),
        ],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen));
          if (snapshot.hasError) return Center(child: TextButton(onPressed: _reload, child: const Text('Could not load reports. Retry')));
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
            Expanded(child: reports.isEmpty ? const Center(child: Text('No reports in this filter.')) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: reports.length, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, index) => _ReportTile(report: reports[index], onEdit: () => _editReport(reports[index])))),
          ]);
        },
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Widget page,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 135,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MunicipalColors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MunicipalColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
  Widget _summary(String label, int value, Color color) => Expanded(child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 11))])));
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.onEdit});
  final Map<String, dynamic> report;
  final VoidCallback onEdit;

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
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(status.replaceAll('_', ' '), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: MunicipalColors.secondaryGreen)), const Icon(Icons.edit_outlined, size: 18, color: MunicipalColors.mutedText)]),
    );
  }
}
