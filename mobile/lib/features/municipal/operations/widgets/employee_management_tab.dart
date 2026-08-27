import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/operations_models.dart';
import '../services/operations_service.dart';

class EmployeeManagementTab extends StatefulWidget {
  const EmployeeManagementTab({super.key});

  @override
  State<EmployeeManagementTab> createState() => _EmployeeManagementTabState();
}

class _EmployeeManagementTabState extends State<EmployeeManagementTab> {
  final OperationsService _apiService = OperationsService();
  List<Employee> _employees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _searchQuery = '';
  String _filterRole = 'ALL';
  String _filterZone = 'ALL';
  String _filterShift = 'ALL';
  String _filterAvailability = 'ALL';
  String _filterActive = 'ALL';

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MunicipalColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12, color: MunicipalColors.primaryText, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.arrow_drop_down, size: 18),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final employees = await _apiService.getAllEmployees();
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _showEmployeeForm([Employee? employee]) {
    final isEditing = employee != null;
    final formKey = GlobalKey<FormState>();
    
    final employeeIdController = TextEditingController(text: employee?.employeeId ?? '');
    final nameController = TextEditingController(text: employee?.name ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    
    String selectedRole = employee?.role ?? 'DRIVER';
    String selectedZone = employee?.assignedZone ?? 'Zone A';
    String selectedShift = employee?.shift ?? 'Morning';
    String selectedStatus = employee?.status ?? 'AVAILABLE';
    bool isActive = employee?.active ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: MunicipalColors.pageBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Profile' : 'Add Driver/Collector',
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
                      const SizedBox(height: 16),
                      
                      // Employee ID
                      TextFormField(
                        controller: employeeIdController,
                        enabled: !isEditing, // cannot edit ID
                        decoration: InputDecoration(
                          labelText: 'Employee ID',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: isEditing,
                          fillColor: isEditing ? MunicipalColors.primaryBg : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter Employee ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (!RegExp(r'^[0-9+\-\s]{7,15}$').hasMatch(value)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role and Shift Rows
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'DRIVER', child: Text('Driver')),
                                DropdownMenuItem(value: 'COLLECTOR', child: Text('Collector')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() => selectedRole = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedShift,
                              decoration: InputDecoration(
                                labelText: 'Shift',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                                DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                                DropdownMenuItem(value: 'Night', child: Text('Night')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() => selectedShift = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Zone and Status Rows
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedZone,
                              decoration: InputDecoration(
                                labelText: 'Assigned Zone',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Zone A', child: Text('Zone A')),
                                DropdownMenuItem(value: 'Zone B', child: Text('Zone B')),
                                DropdownMenuItem(value: 'Zone C', child: Text('Zone C')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() => selectedZone = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                                DropdownMenuItem(value: 'ON_DUTY', child: Text('On Duty')),
                                DropdownMenuItem(value: 'OFF_DUTY', child: Text('Off Duty')),
                                DropdownMenuItem(value: 'LEAVE', child: Text('Leave')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() => selectedStatus = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Active Account'),
                          subtitle: const Text('Deactivating blocks resource assignments'),
                          value: isActive,
                          activeThumbColor: MunicipalColors.secondaryGreen,
                          onChanged: (value) {
                            setModalState(() => isActive = value);
                          },
                        ),
                      ],

                      const SizedBox(height: 24),
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
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final updatedEmp = Employee(
                                id: employee?.id,
                                employeeId: employeeIdController.text.trim(),
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                role: selectedRole,
                                assignedZone: selectedZone,
                                shift: selectedShift,
                                status: selectedStatus,
                                active: isActive,
                              );

                              if (isEditing) {
                                final wasActive = employee.active;
                                final wasAvailable = employee.status.toUpperCase() == 'AVAILABLE' || employee.status.toUpperCase() == 'ON_DUTY';
                                final nextActive = isActive;
                                final nextAvailable = selectedStatus.toUpperCase() == 'AVAILABLE' || selectedStatus.toUpperCase() == 'ON_DUTY';
                                
                                if ((wasActive && !nextActive) || (wasAvailable && !nextAvailable)) {
                                  final isAssigned = await _apiService.isEmployeeAssigned(employee.id!);
                                  if (!context.mounted) return;
                                  if (isAssigned) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Status Change'),
                                        content: Text('Are you sure you want to set ${employee.name} as unavailable? They are currently assigned to an active route.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Yes, Save Changes', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;
                                  }
                                }
                              }

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              
                              setState(() => _isLoading = true);
                              try {
                                if (isEditing) {
                                  await _apiService.updateEmployee(employee.id!, updatedEmp);
                                  _showSnackBar('Profile updated successfully!', Colors.green);
                                } else {
                                  await _apiService.createEmployee(updatedEmp);
                                  _showSnackBar('Employee added successfully!', Colors.green);
                                }
                                _loadEmployees();
                              } catch (e) {
                                setState(() => _isLoading = false);
                                _showErrorDialog(e.toString().replaceAll('Exception:', '').trim());
                              }
                            }
                          },
                          child: Text(isEditing ? 'Save Changes' : 'Add Employee'),
                        ),
                      ),
                    ],
                  ),
                ),
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
            Icon(Icons.error_outline_rounded, color: MunicipalColors.error),
            SizedBox(width: 8),
            Text('Action Failed'),
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

  Future<void> _toggleEmployeeStatus(Employee emp) async {
    try {
      if (emp.active) {
        // Check if assigned to an active route
        final isAssigned = await _apiService.isEmployeeAssigned(emp.id!);
        if (!mounted) return;
        if (isAssigned) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Deactivation'),
              content: Text('Are you sure you want to deactivate ${emp.name}? They are currently assigned to an active route. Deactivating will not cancel their active route.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, Deactivate', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirm != true) return;
        }

        setState(() => _isLoading = true);
        await _apiService.deactivateEmployee(emp.id!);
        if (!mounted) return;
        _showSnackBar('${emp.name} deactivated.', Colors.orange);
      } else {
        setState(() => _isLoading = true);
        final reactivated = Employee(
          id: emp.id,
          employeeId: emp.employeeId,
          name: emp.name,
          phone: emp.phone,
          role: emp.role,
          assignedZone: emp.assignedZone,
          shift: emp.shift,
          status: 'AVAILABLE',
          active: true,
        );
        await _apiService.updateEmployee(emp.id!, reactivated);
        if (!mounted) return;
        _showSnackBar('${emp.name} activated.', Colors.green);
      }
      _loadEmployees();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return MunicipalColors.success;
      case 'ON_DUTY':
        return MunicipalColors.info;
      case 'OFF_DUTY':
        return MunicipalColors.secondaryText;
      case 'LEAVE':
        return MunicipalColors.warning;
      default:
        return Colors.grey;
    }
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
              onPressed: _loadEmployees,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final filteredEmployees = _employees.where((emp) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!emp.name.toLowerCase().contains(query) &&
            !emp.employeeId.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_filterRole != 'ALL' && emp.role != _filterRole) return false;
      if (_filterZone != 'ALL' && emp.assignedZone != _filterZone) return false;
      if (_filterShift != 'ALL' && emp.shift != _filterShift) return false;
      if (_filterAvailability != 'ALL' && emp.status != _filterAvailability) return false;
      if (_filterActive != 'ALL') {
        final isFilterActive = _filterActive == 'ACTIVE';
        if (emp.active != isFilterActive) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MunicipalColors.border),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search by employee name or ID...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterDropdown(
                        label: 'Role',
                        value: _filterRole,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                          DropdownMenuItem(value: 'DRIVER', child: Text('Drivers')),
                          DropdownMenuItem(value: 'COLLECTOR', child: Text('Collectors')),
                        ],
                        onChanged: (val) => setState(() => _filterRole = val!),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterDropdown(
                        label: 'Zone',
                        value: _filterZone,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Zones')),
                          DropdownMenuItem(value: 'Zone A', child: Text('Zone A')),
                          DropdownMenuItem(value: 'Zone B', child: Text('Zone B')),
                          DropdownMenuItem(value: 'Zone C', child: Text('Zone C')),
                        ],
                        onChanged: (val) => setState(() => _filterZone = val!),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterDropdown(
                        label: 'Shift',
                        value: _filterShift,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Shifts')),
                          DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                          DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                          DropdownMenuItem(value: 'Night', child: Text('Night')),
                        ],
                        onChanged: (val) => setState(() => _filterShift = val!),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterDropdown(
                        label: 'Availability',
                        value: _filterAvailability,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                          DropdownMenuItem(value: 'ON_DUTY', child: Text('On Duty')),
                          DropdownMenuItem(value: 'OFF_DUTY', child: Text('Off Duty')),
                          DropdownMenuItem(value: 'LEAVE', child: Text('Leave')),
                        ],
                        onChanged: (val) => setState(() => _filterAvailability = val!),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterDropdown(
                        label: 'Account',
                        value: _filterActive,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Accounts')),
                          DropdownMenuItem(value: 'ACTIVE', child: Text('Active Only')),
                          DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive Only')),
                        ],
                        onChanged: (val) => setState(() => _filterActive = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Employees list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEmployees,
              color: MunicipalColors.secondaryGreen,
              child: filteredEmployees.isEmpty
                  ? Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline_rounded, color: MunicipalColors.secondaryText, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                _employees.isEmpty ? 'No employees registered yet.' : 'No matching employees found.',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                              ),
                              const SizedBox(height: 8),
                              const Text('Try adjusting your search query or filters.', style: TextStyle(color: MunicipalColors.secondaryText)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                      itemCount: filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final emp = filteredEmployees[index];
                        final statusColor = _getStatusColor(emp.status);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: emp.active ? Colors.white : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: emp.active ? MunicipalColors.border : Colors.grey.shade300,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  // Role Color bar
                                  Container(
                                    width: 6,
                                    color: emp.active 
                                      ? (emp.role == 'DRIVER' ? MunicipalColors.deepBlue : MunicipalColors.noticeGreen)
                                      : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  emp.name,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: emp.active ? MunicipalColors.primaryText : MunicipalColors.secondaryText,
                                                    decoration: emp.active ? null : TextDecoration.lineThrough,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: emp.active 
                                                    ? (emp.role == 'DRIVER' ? MunicipalColors.deepBlue.withValues(alpha: 0.1) : MunicipalColors.noticeGreen.withValues(alpha: 0.1))
                                                    : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  emp.role == 'DRIVER' ? 'Driver' : 'Collector',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: emp.active 
                                                      ? (emp.role == 'DRIVER' ? MunicipalColors.deepBlue : MunicipalColors.secondaryGreen)
                                                      : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Status Indicator
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                                ),
                                                child: Text(
                                                  emp.status.replaceFirst('_', ' ').toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.badge_outlined, size: 14, color: MunicipalColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text('ID: ${emp.employeeId}', style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText)),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.phone_outlined, size: 14, color: MunicipalColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text(emp.phone, style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.map_outlined, size: 14, color: MunicipalColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text(emp.assignedZone ?? 'No Zone', style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText)),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.access_time_rounded, size: 14, color: MunicipalColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text(emp.shift ?? 'No Shift', style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Edit and Delete Actions
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: MunicipalColors.secondaryText),
                                        onPressed: () => _showEmployeeForm(emp),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          emp.active ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                                          color: emp.active ? MunicipalColors.secondaryGreen : Colors.grey,
                                          size: 28,
                                        ),
                                        onPressed: () => _toggleEmployeeStatus(emp),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MunicipalColors.secondaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showEmployeeForm(),
      ),
    );
  }
}
