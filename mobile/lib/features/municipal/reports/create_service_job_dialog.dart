import 'package:flutter/material.dart';
import '../../../../services/waste_report_service.dart';
import 'package:mobile/features/municipal/operations/services/operations_service.dart';
import 'package:mobile/features/municipal/operations/models/operations_models.dart';
import '../theme/municipal_colors.dart';

class CreateServiceJobDialog extends StatefulWidget {
  final Map<String, dynamic> initialReport;
  final Function() onJobCreated;

  const CreateServiceJobDialog({
    super.key,
    required this.initialReport,
    required this.onJobCreated,
  });

  @override
  State<CreateServiceJobDialog> createState() => _CreateServiceJobDialogState();
}

class _CreateServiceJobDialogState extends State<CreateServiceJobDialog> {
  final WasteReportService _reportService = WasteReportService();
  final OperationsService _operationsService = OperationsService();
  
  List<Map<String, dynamic>> _allReports = [];
  final List<Map<String, dynamic>> _selectedReports = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedReports.add(widget.initialReport);
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getAdminReports();
      setState(() {
        // Filter out reports that are already assigned to a job or resolved/rejected, and exclude the initial report
        _allReports = reports.where((r) {
          if (r['id'] == widget.initialReport['id']) return false;
          final status = r['status']?.toString().toUpperCase() ?? '';
          if (status == 'RESOLVED' || status == 'REJECTED') return false;
          final team = r['assignedTeam']?.toString() ?? '';
          if (team.startsWith('JOB-')) return false;
          return true;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createJob() async {
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final jobId = 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Store report IDs in description as JSON so we can fetch them later
      final linkedIds = _selectedReports.map((r) => r['id'].toString()).toList();
      
      final newJob = CollectionJob(
        routeId: jobId,
        title: 'Service Job: ${_selectedReports.first['issueType']}',
        description: '{"linkedReports": ${linkedIds.toString()}}',
        zone: _selectedReports.first['location'] ?? 'Unknown',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        status: 'SCHEDULED',
      );
      
      // 1. Create Job in backend
      await _operationsService.createJob(newJob);

      // 2. Update linked reports
      for (final report in _selectedReports) {
        await _reportService.updateAdminReport(
          id: (report['id'] as num).toInt(),
          status: report['status']?.toString() ?? 'SUBMITTED',
          priority: report['priority']?.toString() ?? 'MEDIUM',
          assignedTeam: jobId, // This links the report to the job!
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
        widget.onJobCreated();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Service Job Created successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddReportsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _allReports.where((r) {
              if (_selectedReports.any((sr) => sr['id'] == r['id'])) return false;
              if (_searchQuery.isEmpty) return true;
              final loc = r['location']?.toString().toLowerCase() ?? '';
              final type = r['issueType']?.toString().toLowerCase() ?? '';
              final q = _searchQuery.toLowerCase();
              return loc.contains(q) || type.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: MunicipalColors.pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by location or type...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setModalState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final r = filtered[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(r['referenceNumber'] ?? 'Unknown'),
                            subtitle: Text('${r['issueType']} - ${r['location']}'),
                            trailing: OutlinedButton(
                              onPressed: () {
                                setState(() => _selectedReports.add(r));
                                setModalState(() {});
                              },
                              child: const Text('Add'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: MunicipalColors.secondaryGreen),
              SizedBox(height: 16),
              Text('Creating Service Job...'),
            ],
          ),
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create Service Job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
            const SizedBox(height: 8),
            const Text('A Service Job is a single operational trip. You can add multiple nearby reports to this job to be handled by one team.', style: TextStyle(fontSize: 13, color: MunicipalColors.secondaryText)),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected Reports (${_selectedReports.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _showAddReportsModal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Reports'),
                  style: TextButton.styleFrom(foregroundColor: MunicipalColors.secondaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedReports.length,
                itemBuilder: (context, idx) {
                  final r = _selectedReports[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: MunicipalColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['referenceNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(r['issueType'] ?? '', style: const TextStyle(fontSize: 12)),
                              Text(r['location'] ?? '', style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: r['priority'] == 'HIGH' ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(r['priority'] ?? 'MEDIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: r['priority'] == 'HIGH' ? Colors.red : Colors.orange)),
                        ),
                        if (idx > 0) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                            onPressed: () => setState(() => _selectedReports.removeAt(idx)),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MunicipalColors.secondaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _createJob,
                child: const Text('Create Job', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
