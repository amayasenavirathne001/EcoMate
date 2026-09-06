import 'package:flutter/material.dart';
import '../../../models/schedule_models.dart';
import '../../../models/recycling_centre.dart';
import '../../../models/waste_category.dart';
import '../../../services/schedule_service.dart';
import '../../../services/recycling_service.dart';
import '../theme/municipal_colors.dart';

class CreateSchedulePage extends StatefulWidget {
  final CollectionScheduleModel? scheduleToEdit;

  const CreateSchedulePage({super.key, this.scheduleToEdit});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();
  final RecyclingService _recyclingService = RecyclingService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _zoneController = TextEditingController();

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;

  List<WasteCategory> _categories = [];
  WasteCategory? _selectedCategory;

  String _collectionDateOrDay = '';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _frequency = 'Weekly';
  final List<String> _frequencyOptions = ['One Time', 'Daily', 'Weekly', 'Custom'];

  String _destinationType = 'Municipal Disposal Site';
  final List<String> _destinationTypes = ['Municipal Disposal Site', 'Recycling Centre'];

  List<RecyclingCentre> _compatibleCentres = [];
  RecyclingCentre? _selectedCentre;

  String _status = 'ACTIVE';
  bool _isLoading = true;
  bool _isCentresLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _categories = _recyclingService.getWasteCategories();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final routes = await _scheduleService.getRoutes();
      setState(() {
        _routes = routes.where((r) => r.status == 'ACTIVE').toList();
      });

      if (widget.scheduleToEdit != null) {
        final edit = widget.scheduleToEdit!;
        _nameController.text = edit.scheduleName;
        _zoneController.text = edit.areaOrZone;
        _frequency = edit.frequency;
        _destinationType = edit.destinationType;
        _status = edit.status;
        _collectionDateOrDay = edit.collectionDateOrDay;

        // Route selection
        if (_routes.any((r) => r.id == edit.routeId)) {
          _selectedRoute = _routes.firstWhere((r) => r.id == edit.routeId);
        }

        // Waste category selection
        if (_categories.any((c) => c.id == edit.wasteCategoryId)) {
          _selectedCategory = _categories.firstWhere((c) => c.id == edit.wasteCategoryId);
        }

        // Times parsing
        try {
          _startTime = _parseTimeOfDay(edit.startTime);
          _endTime = _parseTimeOfDay(edit.endTime);
        } catch (_) {}

        // Fetch compatible centers if recycling centre is destination
        if (_selectedCategory != null && _destinationType == 'Recycling Centre') {
          await _loadCompatibleCentres(_selectedCategory!.id);
          if (edit.recyclingCenterId != null && _compatibleCentres.any((rc) => rc.id == edit.recyclingCenterId)) {
            _selectedCentre = _compatibleCentres.firstWhere((rc) => rc.id == edit.recyclingCenterId);
          }
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial data. Check if backend is running.';
        _isLoading = false;
      });
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    // E.g. "09:00 AM" or "14:30"
    final clean = timeStr.trim().toUpperCase();
    final parts = clean.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (parts.length > 1) {
      final ampm = parts[1];
      if (ampm == 'PM' && hour < 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  Future<void> _loadCompatibleCentres(String categoryId) async {
    setState(() {
      _isCentresLoading = true;
    });
    try {
      final centres = await _scheduleService.getCompatibleCentres(categoryId);
      setState(() {
        _compatibleCentres = centres;
        _isCentresLoading = false;
      });
    } catch (e) {
      setState(() {
        _compatibleCentres = [];
        _isCentresLoading = false;
      });
    }
  }

  void _showCentreDetails(RecyclingCentre centre) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: MunicipalColors.pageBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            centre.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(Icons.location_on, 'Address', centre.address),
                _detailRow(Icons.location_city, 'City', centre.city),
                _detailRow(Icons.phone, 'Contact', centre.contactNumber),
                _detailRow(Icons.email, 'Email', centre.email),
                _detailRow(Icons.access_time, 'Hours', centre.operatingHours),
                _detailRow(Icons.check_circle_outline, 'Status', centre.isOpen ? 'Open' : 'Closed'),
                const SizedBox(height: 12),
                const Text('Accepted Materials:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: centre.acceptedMaterials.map((mat) {
                    return Chip(
                      label: Text(mat, style: const TextStyle(fontSize: 11)),
                      backgroundColor: MunicipalColors.primaryBg,
                    );
                  }).toList(),
                ),
                if (centre.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(centre.notes, style: const TextStyle(color: MunicipalColors.secondaryText)),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: MunicipalColors.secondaryGreen)),
            )
          ],
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: MunicipalColors.secondaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: MunicipalColors.primaryText, fontSize: 14),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MunicipalColors.secondaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _collectionDateOrDay = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(bool start) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: start ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (start) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoute == null) {
      _showError('Please select a route');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a waste category');
      return;
    }
    if (_collectionDateOrDay.isEmpty) {
      _showError('Please specify collection date/day');
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('Please select start and end times');
      return;
    }

    // Validate times
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (startMinutes >= endMinutes) {
      _showError('Start time must be before end time');
      return;
    }

    if (_destinationType == 'Recycling Centre' && _selectedCentre == null) {
      _showError('Please select a Recycling Centre');
      return;
    }

    final schedule = CollectionScheduleModel(
      id: widget.scheduleToEdit?.id,
      scheduleName: _nameController.text.trim(),
      routeId: _selectedRoute!.id,
      areaOrZone: _zoneController.text.trim(),
      wasteCategoryId: _selectedCategory!.id,
      collectionDateOrDay: _collectionDateOrDay,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
      frequency: _frequency,
      destinationType: _destinationType,
      recyclingCenterId: _destinationType == 'Recycling Centre' ? _selectedCentre!.id : null,
      status: _status,
      resourceStatus: widget.scheduleToEdit?.resourceStatus ?? 'Not Assigned',
    );

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.scheduleToEdit == null) {
        await _scheduleService.createSchedule(schedule);
      } else {
        await _scheduleService.updateSchedule(widget.scheduleToEdit!.id!, schedule);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule saved successfully!'),
          backgroundColor: MunicipalColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to save collection schedule. Validate backend.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MunicipalColors.error,
      ),
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
        title: Text(
          widget.scheduleToEdit == null ? 'Create Schedule' : 'Edit Schedule',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Schedule Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Schedule Name *',
                        labelStyle: const TextStyle(color: MunicipalColors.secondaryText),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: MunicipalColors.secondaryGreen),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Route Dropdown
                    DropdownButtonFormField<RouteModel>(
                      value: _selectedRoute,
                      hint: const Text('Select Route *'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _routes.map((route) {
                        return DropdownMenuItem(
                          value: route,
                          child: Text('${route.routeCode} - ${route.routeName}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRoute = val;
                          if (val != null) {
                            _zoneController.text = val.areaOrZone;
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Area / Zone
                    TextFormField(
                      controller: _zoneController,
                      decoration: InputDecoration(
                        labelText: 'Area / Zone *',
                        labelStyle: const TextStyle(color: MunicipalColors.secondaryText),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: MunicipalColors.secondaryGreen),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Waste Category
                    DropdownButtonFormField<WasteCategory>(
                      value: _selectedCategory,
                      hint: const Text('Select Waste Category *'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icon, color: cat.binColor, size: 20),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                          _selectedCentre = null;
                        });
                        if (val != null) {
                          _loadCompatibleCentres(val.id);
                        }
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Frequency
                    DropdownButtonFormField<String>(
                      value: _frequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _frequencyOptions.map((f) {
                        return DropdownMenuItem(value: f, child: Text(f));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _frequency = val;
                            if (val == 'Weekly') {
                              _collectionDateOrDay = 'Tuesday';
                            } else {
                              _collectionDateOrDay = '';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Collection Date / Day
                    if (_frequency == 'Weekly')
                      DropdownButtonFormField<String>(
                        value: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                                .contains(_collectionDateOrDay)
                            ? _collectionDateOrDay
                            : 'Tuesday',
                        decoration: InputDecoration(
                          labelText: 'Collection Day *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                            .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _collectionDateOrDay = val;
                            });
                          }
                        },
                      )
                    else if (_frequency == 'Daily')
                      const Text(
                        'Scheduled for every day.',
                        style: TextStyle(fontWeight: FontWeight.w500, color: MunicipalColors.secondaryGreen),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDate,
                              icon: const Icon(Icons.calendar_today, color: MunicipalColors.secondaryGreen),
                              label: Text(
                                _collectionDateOrDay.isEmpty ? 'Select Date *' : _collectionDateOrDay,
                                style: const TextStyle(color: MunicipalColors.primaryText),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: MunicipalColors.border),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Start & End Time
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectTime(true),
                            icon: const Icon(Icons.access_time, color: MunicipalColors.secondaryGreen),
                            label: Text(
                              _startTime == null ? 'Start Time *' : _formatTimeOfDay(_startTime!),
                              style: const TextStyle(color: MunicipalColors.primaryText),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: MunicipalColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectTime(false),
                            icon: const Icon(Icons.access_time, color: MunicipalColors.secondaryGreen),
                            label: Text(
                              _endTime == null ? 'End Time *' : _formatTimeOfDay(_endTime!),
                              style: const TextStyle(color: MunicipalColors.primaryText),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: MunicipalColors.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Destination Type
                    DropdownButtonFormField<String>(
                      value: _destinationType,
                      decoration: InputDecoration(
                        labelText: 'Destination Type *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _destinationTypes.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _destinationType = val;
                            _selectedCentre = null;
                            if (val == 'Recycling Centre' && _selectedCategory != null) {
                              _loadCompatibleCentres(_selectedCategory!.id);
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Destination Selection
                    if (_destinationType == 'Recycling Centre') ...[
                      const Text(
                        'Select Compatible Recycling Centre *',
                        style: TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                      ),
                      const SizedBox(height: 8),
                      if (_isCentresLoading)
                        const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
                      else if (_selectedCategory == null)
                        const Text(
                          'Please select a waste category first to load matching centres.',
                          style: TextStyle(color: MunicipalColors.secondaryText),
                        )
                      else if (_compatibleCentres.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MunicipalColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: MunicipalColors.error.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'No recycling centre currently accepts this waste category.',
                            style: TextStyle(color: MunicipalColors.error, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _compatibleCentres.length,
                          itemBuilder: (context, index) {
                            final centre = _compatibleCentres[index];
                            final isSelected = _selectedCentre?.id == centre.id;

                            return Card(
                              elevation: 0,
                              color: isSelected ? MunicipalColors.primaryBg : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.business,
                                  color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.secondaryText,
                                ),
                                title: Text(
                                  centre.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${centre.address}, ${centre.city}\nAccepted: ${centre.acceptedMaterials.take(2).join(", ")}...',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.info_outline, color: MunicipalColors.secondaryGreen),
                                  onPressed: () => _showCentreDetails(centre),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCentre = centre;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                    ] else ...[
                      TextFormField(
                        initialValue: 'Greenpath Municipal Disposal Yard & Landfill',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Destination Yard',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Status
                    Row(
                      children: [
                        const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Active'),
                          selected: _status == 'ACTIVE',
                          selectedColor: MunicipalColors.secondaryGreen.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _status == 'ACTIVE' ? MunicipalColors.secondaryGreen : MunicipalColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _status = 'ACTIVE');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Inactive'),
                          selected: _status == 'INACTIVE',
                          selectedColor: MunicipalColors.error.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _status == 'INACTIVE' ? MunicipalColors.error : MunicipalColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _status = 'INACTIVE');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: MunicipalColors.secondaryText)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSchedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MunicipalColors.secondaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Save Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
