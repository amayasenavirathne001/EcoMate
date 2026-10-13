import 'package:flutter/material.dart';

import '../../../../models/schedule_models.dart';
import '../../../../services/schedule_service.dart';
import '../services/municipal_special_pickup_service.dart';

class CreateSpecialPickupScheduleScreen extends StatefulWidget {
  const CreateSpecialPickupScheduleScreen({super.key});

  @override
  State<CreateSpecialPickupScheduleScreen> createState() =>
      _CreateSpecialPickupScheduleScreenState();
}

class _CreateSpecialPickupScheduleScreenState
    extends State<CreateSpecialPickupScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  final MunicipalSpecialPickupService _specialPickupService =
      MunicipalSpecialPickupService();

  final _formKey = GlobalKey<FormState>();

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;

  String _selectedDay = 'FRIDAY';

  TimeOfDay _startTime = const TimeOfDay(
    hour: 6,
    minute: 0,
  );

  TimeOfDay _endTime = const TimeOfDay(
    hour: 9,
    minute: 0,
  );

  final _minHouseholdsController =
      TextEditingController(text: '4');

  final _maxHouseholdsController =
      TextEditingController(text: '6');

  final _weightController =
      TextEditingController(text: '3000');

  final _volumeController =
      TextEditingController(text: '18');

  final _deadlineController =
      TextEditingController(text: '12');

  final Set<String> _selectedWasteTypes = {
    'Furniture',
    'Electronic Waste',
    'Bulky Waste',
  };

  final List<String> _wasteTypes = [
    'Furniture',
    'Electronic Waste',
    'Bulky Waste',
    'Garden Waste',
  ];

  final List<String> _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  bool _loadingRoutes = true;
  bool _saving = false;
  String? _routeError;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _minHouseholdsController.dispose();
    _maxHouseholdsController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await _scheduleService.getRoutes();

      if (!mounted) return;

      setState(() {
        _routes = routes;
        _loadingRoutes = false;

        if (routes.isNotEmpty) {
          _selectedRoute = routes.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingRoutes = false;
        _routeError = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _selectStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (selected != null && mounted) {
      setState(() {
        _startTime = selected;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (selected != null && mounted) {
      setState(() {
        _endTime = selected;
      });
    }
  }

  Future<void> _createSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoute == null) {
      _showMessage('Please select a route.');
      return;
    }

    if (_selectedWasteTypes.isEmpty) {
      _showMessage(
        'Select at least one accepted waste type.',
      );
      return;
    }

    final minHouseholds = int.parse(
      _minHouseholdsController.text.trim(),
    );

    final maxHouseholds = int.parse(
      _maxHouseholdsController.text.trim(),
    );

    if (minHouseholds > maxHouseholds) {
      _showMessage(
        'Minimum households cannot be greater than maximum households.',
      );
      return;
    }

    final startMinutes =
        (_startTime.hour * 60) + _startTime.minute;

    final endMinutes =
        (_endTime.hour * 60) + _endTime.minute;

    if (endMinutes <= startMinutes) {
      _showMessage(
        'End time must be after start time.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _specialPickupService.createSchedule(
        routeId: _selectedRoute!.id,
        dayOfWeek: _selectedDay,
        startTime: _apiTime(_startTime),
        endTime: _apiTime(_endTime),
        minHouseholds: minHouseholds,
        maxHouseholds: maxHouseholds,
        maxWeightKg: double.parse(
          _weightController.text.trim(),
        ),
        maxVolumeM3: double.parse(
          _volumeController.text.trim(),
        ),
        joinDeadlineHours: int.parse(
          _deadlineController.text.trim(),
        ),
        acceptedWasteTypes:
            _selectedWasteTypes.join(','),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Special pickup schedule created successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF152033),
          ),
        ),
        title: const Text(
          'Create Schedule',
          style: TextStyle(
            color: Color(0xFF152033),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            120,
          ),
          children: [
            const Text(
              'New Special Pickup Schedule',
              style: TextStyle(
                color: Color(0xFF152033),
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a reusable schedule for '
              'community special waste collections.',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),

            // =================================================
            // ROUTE
            // =================================================

            _sectionTitle('Route'),

            if (_loadingRoutes)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF008F73),
                  ),
                ),
              )
            else if (_routeError != null)
              _errorBox(_routeError!)
            else
              DropdownButtonFormField<RouteModel>(
                initialValue: _selectedRoute,
                decoration: _inputDecoration(
                  'Select route',
                  Icons.route_rounded,
                ),
                items: _routes.map((route) {
                  return DropdownMenuItem<RouteModel>(
                    value: route,
                    child: Text(
                      route.routeName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (route) {
                  setState(() {
                    _selectedRoute = route;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a route';
                  }

                  return null;
                },
              ),

            const SizedBox(height: 22),

            // =================================================
            // DAY
            // =================================================

            _sectionTitle('Collection Day'),

            DropdownButtonFormField<String>(
              initialValue: _selectedDay,
              decoration: _inputDecoration(
                'Collection day',
                Icons.calendar_today_rounded,
              ),
              items: _days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(_displayDay(day)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedDay = value;
                });
              },
            ),

            const SizedBox(height: 22),

            // =================================================
            // TIME
            // =================================================

            _sectionTitle('Collection Time'),

            Row(
              children: [
                Expanded(
                  child: _timeField(
                    label: 'Start Time',
                    value: _startTime,
                    onTap: _selectStartTime,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _timeField(
                    label: 'End Time',
                    value: _endTime,
                    onTap: _selectEndTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // =================================================
            // PARTICIPATION
            // =================================================

            _sectionTitle('Household Participation'),

            const Text(
              'Set the minimum number of households needed '
              'before a vehicle can be assigned, and the '
              'maximum number allowed to join.',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                        _minHouseholdsController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Minimum',
                      Icons.groups_2_outlined,
                    ),
                    validator: (value) =>
                        _positiveIntegerValidator(
                      value,
                      'minimum households',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller:
                        _maxHouseholdsController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Maximum',
                      Icons.people_alt_outlined,
                    ),
                    validator: (value) =>
                        _positiveIntegerValidator(
                      value,
                      'maximum households',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFC7EADF),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF008F73),
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Example: Minimum 4 and Maximum 6 means '
                      'the pickup is open for up to 6 households, '
                      'but a vehicle can be assigned once at least '
                      '4 households have joined.',
                      style: TextStyle(
                        color: Color(0xFF42635A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // =================================================
            // CAPACITY
            // =================================================

            _sectionTitle('Waste Capacity'),

            TextFormField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _inputDecoration(
                'Maximum weight (kg)',
                Icons.scale_outlined,
              ),
              validator: (value) =>
                  _positiveDoubleValidator(
                value,
                'maximum weight',
              ),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _volumeController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _inputDecoration(
                'Maximum volume (m³)',
                Icons.inventory_2_outlined,
              ),
              validator: (value) =>
                  _positiveDoubleValidator(
                value,
                'maximum volume',
              ),
            ),

            const SizedBox(height: 26),

            // =================================================
            // JOIN DEADLINE
            // =================================================

            _sectionTitle('Join Deadline'),

            TextFormField(
              controller: _deadlineController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Hours before pickup',
                Icons.timer_outlined,
                suffixText: 'hours',
              ),
              validator: (value) =>
                  _positiveIntegerValidator(
                value,
                'join deadline',
              ),
            ),

            const SizedBox(height: 26),

            // =================================================
            // WASTE TYPES
            // =================================================

            _sectionTitle('Accepted Waste Types'),

            const Text(
              'Choose the waste types residents '
              'can add to this special pickup.',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _wasteTypes.map((wasteType) {
                final selected =
                    _selectedWasteTypes.contains(
                  wasteType,
                );

                return FilterChip(
                  label: Text(wasteType),
                  selected: selected,
                  selectedColor:
                      const Color(0xFFDDF5EC),
                  checkmarkColor:
                      const Color(0xFF008F73),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF008F73)
                        : const Color(0xFFDCE5E2),
                  ),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedWasteTypes.add(
                          wasteType,
                        );
                      } else {
                        _selectedWasteTypes.remove(
                          wasteType,
                        );
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 35),

            // =================================================
            // CREATE BUTTON
            // =================================================

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _saving ? null : _createSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF008F73),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF91C9BA),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(
                  _saving
                      ? 'Creating...'
                      : 'Create Schedule',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // UI HELPERS
  // ===========================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF152033),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _timeField({
    required String label,
    required TimeOfDay value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          label,
          Icons.schedule_rounded,
        ),
        child: Text(
          _displayTime(value),
          style: const TextStyle(
            color: Color(0xFF152033),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      suffixText: suffixText,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF008F73),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5E2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5E2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF008F73),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD94C4C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF9F3030),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // VALIDATION
  // ===========================================================

  String? _positiveIntegerValidator(
    String? value,
    String field,
  ) {
    final number =
        int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a valid $field';
    }

    return null;
  }

  String? _positiveDoubleValidator(
    String? value,
    String field,
  ) {
    final number =
        double.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a valid $field';
    }

    return null;
  }

  // ===========================================================
  // FORMATTERS
  // ===========================================================

  String _apiTime(TimeOfDay time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _displayTime(TimeOfDay time) {
    final hour =
        time.hourOfPeriod == 0
            ? 12
            : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.period == DayPeriod.am
            ? 'AM'
            : 'PM';

    return '$hour:$minute $period';
  }

  String _displayDay(String day) {
    final value = day.toLowerCase();

    return '${value[0].toUpperCase()}'
        '${value.substring(1)}';
  }

  // ===========================================================
  // MESSAGE
  // ===========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}