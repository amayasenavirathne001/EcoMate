import 'package:flutter/material.dart';
import '../../../models/schedule_models.dart';
import '../../../services/schedule_service.dart';
import '../theme/municipal_colors.dart';

class RouteManagementPage extends StatefulWidget {
  const RouteManagementPage({super.key});

  @override
  State<RouteManagementPage> createState() => _RouteManagementPageState();
}

class _RouteManagementPageState extends State<RouteManagementPage> {
  final ScheduleService _scheduleService = ScheduleService();
  List<RouteModel> _routes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final routes = await _scheduleService.getRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load routes. Make sure backend is running.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRouteStatus(RouteModel route) async {
    final newStatus = route.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await _scheduleService.updateRouteStatus(route.id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route ${route.routeCode} status updated to $newStatus'),
          backgroundColor: MunicipalColors.success,
        ),
      );
      _loadRoutes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update route status'),
          backgroundColor: MunicipalColors.error,
        ),
      );
    }
  }

  void _showAddRouteDialog({RouteModel? routeToEdit}) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: routeToEdit?.routeCode);
    final nameController = TextEditingController(text: routeToEdit?.routeName);
    final zoneController = TextEditingController(text: routeToEdit?.areaOrZone);
    final descController = TextEditingController(text: routeToEdit?.description);
    String status = routeToEdit?.status ?? 'ACTIVE';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: MunicipalColors.pageBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                routeToEdit == null ? "Create New Route" : "Edit Route",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MunicipalColors.primaryText,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: codeController,
                        decoration: InputDecoration(
                          labelText: 'Route Code *',
                          labelStyle: const TextStyle(color: MunicipalColors.secondaryText),
                          hintText: 'e.g. ROUTE-D',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: MunicipalColors.secondaryGreen),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Route Name *',
                          labelStyle: const TextStyle(color: MunicipalColors.secondaryText),
                          hintText: 'e.g. Route D - North Commercial',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: MunicipalColors.secondaryGreen),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: zoneController,
                        decoration: InputDecoration(
                          labelText: 'Area / Zone *',
                          labelStyle: const TextStyle(color: MunicipalColors.secondaryText),
                          hintText: 'e.g. Zone D',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: MunicipalColors.secondaryGreen),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: const TextStyle(color: MunicipalColors.secondaryText),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: MunicipalColors.secondaryGreen),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Active'),
                            selected: status == 'ACTIVE',
                            selectedColor: MunicipalColors.secondaryGreen.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: status == 'ACTIVE' ? MunicipalColors.secondaryGreen : MunicipalColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) setDialogState(() => status = 'ACTIVE');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Inactive'),
                            selected: status == 'INACTIVE',
                            selectedColor: MunicipalColors.error.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: status == 'INACTIVE' ? MunicipalColors.error : MunicipalColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) setDialogState(() => status = 'INACTIVE');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: MunicipalColors.secondaryText)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final data = {
                        'routeCode': codeController.text.trim(),
                        'routeName': nameController.text.trim(),
                        'areaOrZone': zoneController.text.trim(),
                        'description': descController.text.trim(),
                        'status': status,
                      };

                      try {
                        if (routeToEdit == null) {
                          await _scheduleService.createRoute(data);
                        } else {
                          await _scheduleService.updateRoute(routeToEdit.id, data);
                        }
                        Navigator.pop(context);
                        _loadRoutes();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(routeToEdit == null ? 'Failed to create route' : 'Failed to update route'),
                            backgroundColor: MunicipalColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MunicipalColors.secondaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
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
        title: const Text('Route Management', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: MunicipalColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRoutes,
                          style: ElevatedButton.styleFrom(backgroundColor: MunicipalColors.secondaryGreen),
                          child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : _routes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.route_outlined, color: MunicipalColors.secondaryText, size: 64),
                          const SizedBox(height: 16),
                          const Text('No routes created yet.', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddRouteDialog(),
                            style: ElevatedButton.styleFrom(backgroundColor: MunicipalColors.secondaryGreen),
                            child: const Text('Add Route', style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _routes.length,
                      itemBuilder: (context, index) {
                        final route = _routes[index];
                        final isActive = route.status == 'ACTIVE';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: MunicipalColors.border),
                          ),
                          color: isActive ? MunicipalColors.primaryBg : Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: MunicipalColors.secondaryGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        route.routeCode,
                                        style: const TextStyle(
                                          color: MunicipalColors.secondaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: MunicipalColors.secondaryText),
                                          onPressed: () => _showAddRouteDialog(routeToEdit: route),
                                        ),
                                        Switch(
                                          value: isActive,
                                          activeColor: MunicipalColors.secondaryGreen,
                                          onChanged: (_) => _toggleRouteStatus(route),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  route.routeName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: MunicipalColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Area / Zone: ${route.areaOrZone}',
                                  style: const TextStyle(
                                    color: MunicipalColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (route.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    route.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRouteDialog(),
        backgroundColor: MunicipalColors.secondaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
