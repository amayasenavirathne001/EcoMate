import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/operations_models.dart';
import '../services/operations_service.dart';

class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  final OperationsService _apiService = OperationsService();
  List<ResourceAssignment> _assignments = [];
  List<CollectionJob> _unassignedJobs = [];
  
  List<Employee> _allEmployees = [];
  List<Vehicle> _allVehicles = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final assignments = await _apiService.getAllAssignments();
      final unassigned = await _apiService.getUnassignedJobs();
      final employees = await _apiService.getAllEmployees();
      final vehicles = await _apiService.getAllVehicles();

      setState(() {
        _assignments = assignments;
        _unassignedJobs = unassigned;
        _allEmployees = employees;
        _allVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _showAssignmentDialog({CollectionJob? job, ResourceAssignment? assignment}) {
    final isEditing = assignment != null;
    final targetJob = isEditing ? assignment.job : job!;

    // Setup initial selections
    int? selectedDriverId = isEditing ? assignment.driver.id : null;
    int? selectedVehicleId = isEditing ? assignment.vehicle.id : null;
    List<int> selectedCollectorIds = isEditing 
        ? assignment.collectors.map((c) => c.id!).toList() 
        : [];

    // Filter available options + include current selection if editing
    List<Employee> availableDrivers = _allEmployees.where((emp) {
      if (emp.role != 'DRIVER' || !emp.active) return false;
      return emp.status == 'AVAILABLE' || (isEditing && emp.id == assignment.driver.id);
    }).toList();

    List<Vehicle> availableVehicles = _allVehicles.where((v) {
      if (!v.active) return false;
      return v.status == 'AVAILABLE' || (isEditing && v.id == assignment.vehicle.id);
    }).toList();

    List<Employee> availableCollectors = _allEmployees.where((emp) {
      if (emp.role != 'COLLECTOR' || !emp.active) return false;
      return emp.status == 'AVAILABLE' || (isEditing && assignment.collectors.any((c) => c.id == emp.id));
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: MunicipalColors.pageBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Reassign Resources' : 'Assign Resources',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MunicipalColors.primaryText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Job Detail Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MunicipalColors.primaryBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MunicipalColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route: ${targetJob.routeId} – ${targetJob.title}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zone: ${targetJob.zone}  |  Time: ${_formatDateTimeRange(targetJob.startTime, targetJob.endTime)}',
                          style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Form Fields (Scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assignment execution date and time
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: MunicipalColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: MunicipalColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: MunicipalColors.secondaryGreen),
                                const SizedBox(width: 8),
                                const Text(
                                  'Assignment Timestamp: ',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MunicipalColors.secondaryText),
                                ),
                                Text(
                                  DateTime.now().toLocal().toString().substring(0, 16),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MunicipalColors.primaryText),
                                ),
                              ],
                            ),
                          ),
                          // Select Driver
                          const Text(
                            'Select Driver (Choose 1)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MunicipalColors.primaryText),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: selectedDriverId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Choose available driver',
                            ),
                            items: availableDrivers.map((driver) {
                              return DropdownMenuItem<int>(
                                value: driver.id,
                                child: Text('${driver.name} (Shift: ${driver.shift})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() => selectedDriverId = value);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Select Vehicle
                          const Text(
                            'Select Vehicle (Choose 1)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MunicipalColors.primaryText),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: selectedVehicleId,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.local_shipping_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Choose available vehicle',
                            ),
                            items: availableVehicles.map((v) {
                              return DropdownMenuItem<int>(
                                value: v.id,
                                child: Text('${v.registrationNumber} (${v.vehicleType} - ${v.capacity}T)'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() => selectedVehicleId = value);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Select Collectors (Multi-select list)
                          const Text(
                            'Select Collectors (Choose 1 or more)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MunicipalColors.primaryText),
                          ),
                          const SizedBox(height: 8),
                          if (availableCollectors.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('No collectors available.', style: TextStyle(color: Colors.red)),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: availableCollectors.length,
                                itemBuilder: (context, idx) {
                                  final col = availableCollectors[idx];
                                  final isChecked = selectedCollectorIds.contains(col.id);
                                  
                                  return CheckboxListTile(
                                    title: Text(col.name),
                                    subtitle: Text('Shift: ${col.shift} | Zone: ${col.assignedZone}'),
                                    value: isChecked,
                                    activeColor: MunicipalColors.secondaryGreen,
                                    onChanged: (value) {
                                      setModalState(() {
                                        if (value == true) {
                                          selectedCollectorIds.add(col.id!);
                                        } else {
                                          selectedCollectorIds.remove(col.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Confirm Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MunicipalColors.secondaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (selectedDriverId == null || selectedVehicleId == null || selectedCollectorIds.isEmpty)
                          ? null
                          : () async {
                              final req = AssignmentRequest(
                                jobId: targetJob.id!,
                                vehicleId: selectedVehicleId!,
                                driverId: selectedDriverId!,
                                collectorIds: selectedCollectorIds,
                              );

                              Navigator.pop(context);
                              setState(() => _isLoading = true);

                              try {
                                if (isEditing) {
                                  await _apiService.updateAssignment(assignment.id!, req);
                                  _showSnackBar('Assignment successfully updated!', Colors.green);
                                } else {
                                  await _apiService.createAssignment(req);
                                  _showSnackBar('Assignment successfully created!', Colors.green);
                                }
                                _loadData();
                              } catch (e) {
                                setState(() => _isLoading = false);
                                _showErrorDialog(e.toString().replaceAll('Exception:', '').trim());
                              }
                            },
                      child: Text(isEditing ? 'Confirm Reassignment' : 'Confirm Assignment'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: MunicipalColors.error),
            SizedBox(width: 8),
            Text('Assignment Rejected'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: MunicipalColors.secondaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancelAssignment(ResourceAssignment assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Assignment?'),
        content: Text('Are you sure you want to cancel the assignment for Route ${assignment.job.routeId}? The resources will be set back to Available status.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _apiService.cancelAssignment(assignment.id!);
        _showSnackBar('Assignment cancelled.', Colors.orange);
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString().replaceAll('Exception:', '').trim());
      }
    }
  }

  Future<void> _completeAssignment(ResourceAssignment assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Assignment?'),
        content: Text('Are you sure you want to mark Route ${assignment.job.routeId} assignment as completed? This will set all assigned resources (driver, vehicle, collectors) back to Available status.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Complete', style: TextStyle(color: MunicipalColors.secondaryGreen)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _apiService.completeAssignment(assignment.id!);
        _showSnackBar('Assignment marked as completed.', Colors.green);
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString().replaceAll('Exception:', '').trim());
      }
    }
  }

  void _showDetailsDialog(ResourceAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: MunicipalColors.secondaryGreen),
            const SizedBox(width: 8),
            Text('Route ${assignment.job.routeId} Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                assignment.job.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MunicipalColors.primaryText),
              ),
              if (assignment.job.description != null && assignment.job.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  assignment.job.description!,
                  style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText),
                ),
              ],
              const Divider(height: 24),
              _buildDetailRow('Status', assignment.status, isBadge: true),
              _buildDetailRow('Zone', assignment.job.zone),
              _buildDetailRow('Scheduled Time', _formatDateTimeRange(assignment.job.startTime, assignment.job.endTime)),
              _buildDetailRow('Assignment Date', assignment.assignmentDate.toLocal().toString().substring(0, 16)),
              const Divider(height: 24),
              const Text('ASSIGNED RESOURCES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: MunicipalColors.secondaryText, letterSpacing: 1.1)),
              const SizedBox(height: 12),
              _buildResourceRow(Icons.person_rounded, 'Driver', '${assignment.driver.name} (${assignment.driver.employeeId})', 'Phone: ${assignment.driver.phone}'),
              const SizedBox(height: 12),
              _buildResourceRow(Icons.local_shipping_rounded, 'Vehicle', assignment.vehicle.registrationNumber, '${assignment.vehicle.vehicleType} (Capacity: ${assignment.vehicle.capacity}T)'),
              const SizedBox(height: 12),
              _buildResourceRow(
                Icons.people_rounded, 
                'Collectors', 
                assignment.collectors.map((c) => c.name).join(', '), 
                assignment.collectors.map((c) => c.employeeId).join(', ')
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: MunicipalColors.secondaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 13)),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (value.toUpperCase() == 'COMPLETED' ? Colors.green : (value.toUpperCase() == 'CANCELLED' ? Colors.grey : MunicipalColors.secondaryGreen)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  color: value.toUpperCase() == 'COMPLETED' ? Colors.green : (value.toUpperCase() == 'CANCELLED' ? Colors.grey : MunicipalColors.secondaryGreen)
                ),
              ),
            )
          else
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MunicipalColors.primaryText)),
        ],
      ),
    );
  }

  Widget _buildResourceRow(IconData icon, String title, String name, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: MunicipalColors.secondaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: MunicipalColors.secondaryText)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MunicipalColors.primaryText)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTimeRange(DateTime start, DateTime end) {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    final dayStr = '${start.month}/${start.day}';
    return '$dayStr ($startStr - $endStr)';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: MunicipalColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: MunicipalColors.primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: MunicipalColors.secondaryGreen),
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: MunicipalColors.secondaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Unassigned Routes
              Row(
                children: [
                  const Icon(Icons.pending_actions_rounded, color: MunicipalColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    'Unassigned Routes (${_unassignedJobs.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_unassignedJobs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Text('All scheduled routes have been assigned!', style: TextStyle(color: MunicipalColors.secondaryText)),
                  ),
                )
              else
                ..._unassignedJobs.map((job) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MunicipalColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${job.routeId} – ${job.title}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Zone: ${job.zone}  |  Time: ${_formatDateTimeRange(job.startTime, job.endTime)}',
                                style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MunicipalColors.secondaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showAssignmentDialog(job: job),
                          child: const Text('Assign', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Section 2: Active Assignments
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, color: MunicipalColors.secondaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Active Assignments (${_assignments.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_assignments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Text('No active assignments found.', style: TextStyle(color: MunicipalColors.secondaryText)),
                  ),
                )
              else
                ..._assignments.map((assignment) {
                  final activeColors = assignment.status.toUpperCase() == 'COMPLETED'
                      ? Colors.green
                      : (assignment.status.toUpperCase() == 'CANCELLED' ? Colors.grey : MunicipalColors.secondaryGreen);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MunicipalColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (Route and Status)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Route ${assignment.job.routeId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MunicipalColors.primaryText),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: activeColors.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  assignment.status,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: activeColors),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            assignment.job.title,
                            style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText),
                          ),
                          const Divider(height: 20),
                          
                          // Assignment details
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 16, color: MunicipalColors.secondaryText),
                              const SizedBox(width: 6),
                              Text('Driver: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(assignment.driver.name, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.local_shipping_rounded, size: 16, color: MunicipalColors.secondaryText),
                              const SizedBox(width: 6),
                              Text('Vehicle: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(assignment.vehicle.registrationNumber, style: const TextStyle(fontSize: 13)),
                              Text(' (${assignment.vehicle.vehicleType})', style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.people_rounded, size: 16, color: MunicipalColors.secondaryText),
                              const SizedBox(width: 6),
                              Text('Collectors: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Expanded(
                                child: Text(
                                  assignment.collectors.map((c) => c.name).join(', '),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: MunicipalColors.secondaryText),
                              const SizedBox(width: 6),
                              Text('Scheduled: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(
                                _formatDateTimeRange(assignment.job.startTime, assignment.job.endTime),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          
                          const Divider(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: MunicipalColors.secondaryGreen),
                                    foregroundColor: MunicipalColors.secondaryGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _showDetailsDialog(assignment),
                                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                                  label: const Text('Details', style: TextStyle(fontSize: 12)),
                                ),
                                if (assignment.status.toUpperCase() != 'CANCELLED' && assignment.status.toUpperCase() != 'COMPLETED') ...[
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _cancelAssignment(assignment),
                                    icon: const Icon(Icons.cancel_outlined, size: 16),
                                    label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MunicipalColors.secondaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showAssignmentDialog(assignment: assignment),
                                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                                    label: const Text('Reassign', style: TextStyle(fontSize: 12)),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _completeAssignment(assignment),
                                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                    label: const Text('Complete', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
