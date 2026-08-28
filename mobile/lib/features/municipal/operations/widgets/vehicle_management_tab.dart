import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/operations_models.dart';
import '../services/operations_service.dart';

class VehicleManagementTab extends StatefulWidget {
  const VehicleManagementTab({super.key});

  @override
  State<VehicleManagementTab> createState() => _VehicleManagementTabState();
}

class _VehicleManagementTabState extends State<VehicleManagementTab> {
  final OperationsService _apiService = OperationsService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _searchQuery = '';
  String _filterType = 'ALL';
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
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final vehicles = await _apiService.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _showVehicleForm([Vehicle? vehicle]) {
    final isEditing = vehicle != null;
    final formKey = GlobalKey<FormState>();

    final regNumberController = TextEditingController(text: vehicle?.registrationNumber ?? '');
    final capacityController = TextEditingController(text: vehicle?.capacity.toString() ?? '');

    String selectedType = vehicle?.vehicleType ?? 'Compactor';
    String selectedStatus = vehicle?.status ?? 'AVAILABLE';
    DateTime selectedServiceDate = vehicle?.lastServiceDate ?? DateTime.now();
    DateTime? selectedNextServiceDate = vehicle?.nextServiceDate;
    bool isActive = vehicle?.active ?? true;

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
                            isEditing ? 'Edit Vehicle Info' : 'Register Vehicle',
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

                      // Registration Number
                      TextFormField(
                        controller: regNumberController,
                        enabled: !isEditing,
                        decoration: InputDecoration(
                          labelText: 'Registration Number',
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: isEditing,
                          fillColor: isEditing ? MunicipalColors.primaryBg : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter Registration Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Capacity
                      TextFormField(
                        controller: capacityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Load Capacity (Tons)',
                          prefixIcon: const Icon(Icons.line_weight_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter capacity';
                          }
                          final val = double.tryParse(value);
                          if (val == null) {
                            return 'Capacity must be a number';
                          }
                          if (val <= 0) {
                            return 'Capacity must be greater than zero';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Type dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Compactor', child: Text('Compactor (Garbage Truck)')),
                          DropdownMenuItem(value: 'Dumper', child: Text('Dumper Truck')),
                          DropdownMenuItem(value: 'Flatbed', child: Text('Flatbed Truck')),
                          DropdownMenuItem(value: 'Roll-off', child: Text('Roll-off Container Truck')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Availability Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                          DropdownMenuItem(value: 'ON_DUTY', child: Text('On Duty')),
                          DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                          DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Last Service Date Datepicker
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedServiceDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: MunicipalColors.secondaryGreen,
                                    onPrimary: Colors.white,
                                    onSurface: MunicipalColors.primaryText,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() => selectedServiceDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Last Serviced: ${selectedServiceDate.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(fontSize: 16, color: MunicipalColors.primaryText),
                              ),
                              const Icon(Icons.calendar_today_outlined, color: MunicipalColors.secondaryGreen),
                            ],
                          ),
                        ),
                      ),

                      // Next Service Date Datepicker (Optional)
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedNextServiceDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 1000)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: MunicipalColors.secondaryGreen,
                                    onPrimary: Colors.white,
                                    onSurface: MunicipalColors.primaryText,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() => selectedNextServiceDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedNextServiceDate == null
                                    ? 'Next Service Due (Optional)'
                                    : 'Next Service Due: ${selectedNextServiceDate!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: selectedNextServiceDate == null ? MunicipalColors.secondaryText : MunicipalColors.primaryText
                                ),
                              ),
                              Row(
                                children: [
                                  if (selectedNextServiceDate != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.red, size: 20),
                                      onPressed: () {
                                        setModalState(() => selectedNextServiceDate = null);
                                      },
                                    ),
                                  const Icon(Icons.calendar_today_outlined, color: MunicipalColors.secondaryGreen),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Active Fleet Resource'),
                          subtitle: const Text('Deactivation marks vehicle as inactive'),
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
                              final updatedVehicle = Vehicle(
                                id: vehicle?.id,
                                registrationNumber: regNumberController.text.trim().toUpperCase(),
                                vehicleType: selectedType,
                                capacity: double.parse(capacityController.text),
                                status: selectedStatus,
                                lastServiceDate: selectedServiceDate,
                                nextServiceDate: selectedNextServiceDate,
                                active: isActive,
                              );

                              if (isEditing) {
                                final wasActive = vehicle.active;
                                final wasAvailable = vehicle.status.toUpperCase() == 'AVAILABLE' || vehicle.status.toUpperCase() == 'ON_DUTY';
                                final nextActive = isActive;
                                final nextAvailable = selectedStatus.toUpperCase() == 'AVAILABLE' || selectedStatus.toUpperCase() == 'ON_DUTY';

                                 if ((wasActive && !nextActive) || (wasAvailable && !nextAvailable)) {
                                  final isAssigned = await _apiService.isVehicleAssigned(vehicle.id!);
                                  if (!context.mounted) return;
                                  if (isAssigned) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Vehicle Status Change'),
                                        content: Text('Are you sure you want to set vehicle ${vehicle.registrationNumber} as unavailable? It is currently assigned to an active route.'),
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
                                  await _apiService.updateVehicle(vehicle.id!, updatedVehicle);
                                  _showSnackBar('Vehicle details updated!', Colors.green);
                                } else {
                                  await _apiService.createVehicle(updatedVehicle);
                                  _showSnackBar('Vehicle registered successfully!', Colors.green);
                                }
                                _loadVehicles();
                              } catch (e) {
                                setState(() => _isLoading = false);
                                _showErrorDialog(e.toString().replaceAll('Exception:', '').trim());
                              }
                            }
                          },
                          child: Text(isEditing ? 'Save Details' : 'Register Vehicle'),
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

  Future<void> _toggleVehicleStatus(Vehicle vehicle) async {
    try {
      if (vehicle.active) {
        // Check if assigned to an active route
        final isAssigned = await _apiService.isVehicleAssigned(vehicle.id!);
        if (!mounted) return;
        if (isAssigned) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Deactivation'),
              content: Text('Are you sure you want to deactivate vehicle ${vehicle.registrationNumber}? It is currently assigned to an active route. Deactivating will not cancel the route.'),
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
        await _apiService.deactivateVehicle(vehicle.id!);
        if (!mounted) return;
        _showSnackBar('${vehicle.registrationNumber} deactivated.', Colors.orange);
      } else {
        setState(() => _isLoading = true);
        final reactivated = Vehicle(
          id: vehicle.id,
          registrationNumber: vehicle.registrationNumber,
          vehicleType: vehicle.vehicleType,
          capacity: vehicle.capacity,
          status: 'AVAILABLE',
          lastServiceDate: vehicle.lastServiceDate,
          nextServiceDate: vehicle.nextServiceDate,
          active: true,
        );
        await _apiService.updateVehicle(vehicle.id!, reactivated);
        if (!mounted) return;
        _showSnackBar('${vehicle.registrationNumber} reactivated.', Colors.green);
      }
      _loadVehicles();
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
      case 'MAINTENANCE':
        return MunicipalColors.warning;
      case 'INACTIVE':
        return MunicipalColors.error;
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
              onPressed: _loadVehicles,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final filteredVehicles = _vehicles.where((vehicle) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!vehicle.registrationNumber.toLowerCase().contains(query) &&
            !vehicle.vehicleType.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_filterType != 'ALL' && vehicle.vehicleType != _filterType) return false;
      if (_filterAvailability != 'ALL' && vehicle.status != _filterAvailability) return false;
      if (_filterActive != 'ALL') {
        final isFilterActive = _filterActive == 'ACTIVE';
        if (vehicle.active != isFilterActive) return false;
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
                    hintText: 'Search by registration number or type...',
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
                        label: 'Type',
                        value: _filterType,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Types')),
                          DropdownMenuItem(value: 'Compactor', child: Text('Compactor')),
                          DropdownMenuItem(value: 'Dumper', child: Text('Dumper')),
                          DropdownMenuItem(value: 'Flatbed', child: Text('Flatbed')),
                          DropdownMenuItem(value: 'Roll-off', child: Text('Roll-off')),
                        ],
                        onChanged: (val) => setState(() => _filterType = val!),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterDropdown(
                        label: 'Status',
                        value: _filterAvailability,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                          DropdownMenuItem(value: 'ON_DUTY', child: Text('On Duty')),
                          DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                          DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
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

          // Vehicles list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVehicles,
              color: MunicipalColors.secondaryGreen,
              child: filteredVehicles.isEmpty
                  ? Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_shipping_outlined, color: MunicipalColors.secondaryText, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                _vehicles.isEmpty ? 'No vehicles in fleet.' : 'No matching vehicles found.',
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
                      itemCount: filteredVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = filteredVehicles[index];
                        final statusColor = _getStatusColor(vehicle.status);

                        Widget serviceIndicator = const SizedBox.shrink();
                        if (vehicle.nextServiceDate != null) {
                          final today = DateTime.now();
                          final diff = vehicle.nextServiceDate!.difference(today).inDays;
                          if (vehicle.nextServiceDate!.isBefore(today)) {
                            serviceIndicator = Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Service OVERDUE! (${vehicle.nextServiceDate!.toLocal().toString().split(' ')[0]})',
                                    style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          } else if (diff >= 0 && diff <= 7) {
                            serviceIndicator = Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Service Due Soon: ${vehicle.nextServiceDate!.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            serviceIndicator = Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: MunicipalColors.secondaryText),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Next Service: ${vehicle.nextServiceDate!.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: vehicle.active ? Colors.white : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: vehicle.active ? MunicipalColors.border : Colors.grey.shade300,
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
                                  // Active Indicator Color bar
                                  Container(
                                    width: 6,
                                    color: vehicle.active ? MunicipalColors.secondaryGreen : Colors.grey,
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
                                                  vehicle.registrationNumber,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: vehicle.active ? MunicipalColors.primaryText : MunicipalColors.secondaryText,
                                                    decoration: vehicle.active ? null : TextDecoration.lineThrough,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: vehicle.active ? MunicipalColors.secondaryGreen.withValues(alpha: 0.1) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  vehicle.vehicleType,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: vehicle.active ? MunicipalColors.secondaryGreen : Colors.grey,
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
                                                  vehicle.status.replaceFirst('_', ' ').toUpperCase(),
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
                                              const Icon(Icons.line_weight_rounded, size: 14, color: MunicipalColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text('Capacity: ${vehicle.capacity} Tons', style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText)),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.build_outlined, size: 14, color: MunicipalColors.secondaryText),
                                              const SizedBox(width: 4),
                                              Text(
                                                vehicle.lastServiceDate != null
                                                  ? 'Serviced: ${vehicle.lastServiceDate!.toLocal().toString().split(' ')[0]}'
                                                  : 'No Service Records',
                                                style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText),
                                              ),
                                            ],
                                          ),
                                          serviceIndicator,
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Actions
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: MunicipalColors.secondaryText),
                                        onPressed: () => _showVehicleForm(vehicle),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          vehicle.active ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                                          color: vehicle.active ? MunicipalColors.secondaryGreen : Colors.grey,
                                          size: 28,
                                        ),
                                        onPressed: () => _toggleVehicleStatus(vehicle),
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
        onPressed: () => _showVehicleForm(),
      ),
    );
  }
}
