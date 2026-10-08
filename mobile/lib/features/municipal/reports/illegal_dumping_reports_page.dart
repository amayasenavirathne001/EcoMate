import 'package:flutter/material.dart';
import '../../../services/report_filters.dart';
import '../../../services/report_review.dart';
import '../../../services/waste_report_service.dart';
import '../theme/municipal_colors.dart';
import 'report_location_map_page.dart';
import 'create_service_job_dialog.dart';

class IllegalDumpingReportsPage extends StatefulWidget {
  const IllegalDumpingReportsPage({super.key});

  @override
  State<IllegalDumpingReportsPage> createState() => _IllegalDumpingReportsPageState();
}

class _IllegalDumpingReportsPageState extends State<IllegalDumpingReportsPage> {
  final _service = WasteReportService();
  final _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _reports;
  String _filter = 'All';
  String _priorityFilter = 'All';
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
    var reviewNotes = '';
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        final validationMessage = validateReportTransition(
          currentStatus: report['status']?.toString() ?? 'SUBMITTED',
          nextStatus: status,
          assignedTeam: team,
          reviewNotes: reviewNotes,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(report['issueType']?.toString() ?? 'Report', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MunicipalColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MunicipalColors.border),
              ),
              child: Text(
                buildReviewSummary(report),
                style: const TextStyle(color: MunicipalColors.primaryText, height: 1.5, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MunicipalColors.border),
              ),
              child: Text(
                buildVerificationChecklist(report),
                style: const TextStyle(color: MunicipalColors.primaryText, fontSize: 11, height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
            if (team.startsWith('JOB-'))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MunicipalColors.secondaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: MunicipalColors.secondaryGreen),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Service Job', style: TextStyle(fontSize: 12, color: MunicipalColors.secondaryGreen, fontWeight: FontWeight.bold)),
                        Text(team, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                         final pageMessenger = ScaffoldMessenger.of(context);
                         Navigator.pop(context);
                         pageMessenger.showSnackBar(const SnackBar(content: Text('Please navigate to Operations -> Schedule -> Assignments to view this job')));
                      },
                      child: const Text('View Job'),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final pageMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    _createJobFromReport(report, pageMessenger);
                  },
                  icon: const Icon(Icons.add_task_rounded, size: 20),
                  label: const Text('Create Service Job'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MunicipalColors.secondaryGreen,
                    side: const BorderSide(color: MunicipalColors.secondaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
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
            const SizedBox(height: 8),
            TextFormField(
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Review notes / comments'),
              onChanged: (value) => reviewNotes = value,
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 10),
              Text(validationMessage, style: const TextStyle(color: MunicipalColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final error = validateReportTransition(
                    currentStatus: report['status']?.toString() ?? 'SUBMITTED',
                    nextStatus: status,
                    assignedTeam: team,
                    reviewNotes: reviewNotes,
                  );
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))); 
                    return;
                  }
                  Navigator.pop(context, {'status': status, 'priority': priority, 'assignedTeam': team, 'reviewNotes': reviewNotes});
                },
                child: const Text('Save update'),
              ),
            ),
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
      if (mounted) {
        setState(() {
          _reports = Future.value(updatedReports);
        });
      }
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

  Future<void> _setPriority(Map<String, dynamic> report, String priority) async {
    final currentPriority = (report['priority'] ?? 'MEDIUM').toString().toUpperCase();
    if (currentPriority == priority) return;

    try {
      final updated = await _service.updateAdminReport(
        id: (report['id'] as num).toInt(),
        status: (report['status'] ?? 'SUBMITTED').toString(),
        priority: priority,
        assignedTeam: (report['assignedTeam'] ?? '').toString(),
      );
      final currentReports = await _reports;
      if (!mounted) return;
      setState(() {
        _reports = Future.value(currentReports.map((currentReport) {
          return currentReport['id'] == updated['id'] ? updated : currentReport;
        }).toList());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Priority set to $priority')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update priority: $error')),
        );
      }
    }
  }

  void _createJobFromReport(Map<String, dynamic> report, [ScaffoldMessengerState? messenger]) {
    final activeMessenger = messenger ?? ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (_) => CreateServiceJobDialog(
        initialReport: report,
        onJobCreated: () {
          _reload();
          activeMessenger.showSnackBar(
            const SnackBar(content: Text('Service Job created successfully. Go to Schedule to assign.'))
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Illegal Dumping', style: TextStyle(fontWeight: FontWeight.bold)),
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
          final reports = sortReportsForReview(
            filterReports(
              all,
              query: _searchController.text,
              status: _filter,
              priority: _priorityFilter,
            ),
          );
          return Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: Row(children: [
              _summary('Open', all.where((item) => item['status'] != 'RESOLVED').length, MunicipalColors.warning),
              _summary('Review', all.where((item) => item['status'] == 'IN_REVIEW').length, MunicipalColors.info),
              _summary('Resolved', all.where((item) => item['status'] == 'RESOLVED').length, MunicipalColors.success),
              _summary('High', all.where((item) => (item['priority'] ?? 'MEDIUM').toString().toUpperCase() == 'HIGH').length, MunicipalColors.error),
            ])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by issue, location, or reference',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MunicipalColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MunicipalColors.border)),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'HIGH', 'MEDIUM', 'LOW'].map((item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(item == 'All' ? 'All priorities' : item),
                    selected: _priorityFilter == item,
                    onSelected: (_) => setState(() => _priorityFilter = item),
                  ),
                )).toList(),
              ),
            ),
            Expanded(child: reports.isEmpty ? const Center(child: Text('No reports match your current filters.')) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: reports.length, separatorBuilder: (_, _) => const SizedBox(height: 10), itemBuilder: (_, index) => _ReportTile(report: reports[index], onEdit: () => _editReport(reports[index]), onViewLocation: () => _viewLocation(reports[index]), onCreateJob: () => _createJobFromReport(reports[index]), onSetPriority: (priority) => _setPriority(reports[index], priority)))),
          ]);
        },
      ),
    );
  }

  Widget _summary(String label, int value, Color color) => Expanded(child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 11))])));
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.onEdit, required this.onViewLocation, required this.onCreateJob, required this.onSetPriority});
  final Map<String, dynamic> report;
  final VoidCallback onEdit;
  final VoidCallback onViewLocation;
  final VoidCallback onCreateJob;
  final ValueChanged<String> onSetPriority;

  @override
  Widget build(BuildContext context) {
    final status = report['status']?.toString() ?? 'SUBMITTED';
    final priority = report['priority']?.toString() ?? 'MEDIUM';
    final normalizedPriority = priority.toUpperCase();
    final priorityColor = switch (normalizedPriority) {
      'HIGH' => MunicipalColors.error,
      'LOW' => MunicipalColors.success,
      _ => MunicipalColors.warning,
    };
    final team = report['assignedTeam']?.toString() ?? '';
    return ListTile(
      onTap: onEdit,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: MunicipalColors.border)),
      leading: CircleAvatar(backgroundColor: MunicipalColors.surface, child: Icon(Icons.report_problem_outlined, color: status == 'RESOLVED' ? MunicipalColors.success : MunicipalColors.secondaryGreen)),
      title: Text(report['issueType']?.toString() ?? 'Waste report', style: const TextStyle(fontWeight: FontWeight.w700, color: MunicipalColors.primaryText)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${report['referenceNumber']}\n${report['location']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MunicipalColors.secondaryText, height: 1.4)),
          PopupMenuButton<String>(
            tooltip: 'Set issue priority',
            onSelected: onSetPriority,
            itemBuilder: (context) => const ['HIGH', 'MEDIUM', 'LOW'].map((value) => PopupMenuItem(value: value, child: Text(value))).toList(),
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.12),
                border: Border.all(color: priorityColor.withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_outlined, size: 14, color: priorityColor),
                  const SizedBox(width: 4),
                  Text('$normalizedPriority PRIORITY', style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: priorityColor),
                ],
              ),
            ),
          ),
        ],
      ),
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
              if (!team.startsWith('JOB-'))
                IconButton(
                  onPressed: onCreateJob,
                  tooltip: 'Create Service Job',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_task_rounded, size: 18, color: MunicipalColors.secondaryGreen),
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
