import 'package:flutter/material.dart';

import '../services/municipal_special_pickup_service.dart';

class CreateSpecialPickupScreen extends StatefulWidget {
  const CreateSpecialPickupScreen({super.key});

  @override
  State<CreateSpecialPickupScreen> createState() =>
      _CreateSpecialPickupScreenState();
}

class _CreateSpecialPickupScreenState
    extends State<CreateSpecialPickupScreen> {
  final MunicipalSpecialPickupService _service =
      MunicipalSpecialPickupService();

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

List<Map<String, dynamic>> _schedules = [];
Map<String, dynamic>? _selectedSchedule;
DateTime? _pickupDate;

List<Map<String, dynamic>> _vehicles = [];
Map<String, dynamic>? _selectedVehicle;

bool _loadingSchedules = true;
bool _loadingVehicles = true;
bool _creating = false;

String? _scheduleError;
String? _vehicleError;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _loadVehicles();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await _service.getSchedules();

      if (!mounted) return;

      setState(() {
        _schedules = schedules;
        _loadingSchedules = false;

        if (schedules.isNotEmpty) {
          _selectedSchedule = schedules.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSchedules = false;
        _scheduleError =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }
  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _service.getVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _loadingVehicles = false;

        if (vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingVehicles = false;
        _vehicleError =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _selectPickupDate() async {
    final initialDate = _nextValidDate();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selected == null || !mounted) return;

    final scheduleDay =
        _selectedSchedule?['dayOfWeek']?.toString();

    if (scheduleDay != null &&
        !_dateMatchesSchedule(selected, scheduleDay)) {
      _showMessage(
        'Please select a ${_displayDay(scheduleDay)} '
        'because this schedule runs on '
        '${_displayDay(scheduleDay)}.',
      );
      return;
    }

    setState(() {
      _pickupDate = selected;
    });
  }

  Future<void> _createPickup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSchedule == null) {
      _showMessage('Please select a schedule.');
      return;
    }

    if (_pickupDate == null) {
      _showMessage('Please select a pickup date.');
      return;
    }
    if (_selectedVehicle == null) {
      _showMessage('Please select a vehicle.');
      return;
    }

    final scheduleId =
        _toInt(_selectedSchedule!['id']);

    if (scheduleId == null) {
      _showMessage('Invalid schedule selected.');
      return;
    }
    final vehicleId =
    _toInt(_selectedVehicle!['id']);

    if (vehicleId == null) {
      _showMessage('Invalid vehicle selected.');
      return;
    }

    final scheduleDay =
        _selectedSchedule!['dayOfWeek']?.toString();

    if (scheduleDay != null &&
        !_dateMatchesSchedule(
          _pickupDate!,
          scheduleDay,
        )) {
      _showMessage(
        'Pickup date must be a '
        '${_displayDay(scheduleDay)}.',
      );
      return;
    }

    setState(() {
      _creating = true;
    });

    try {
      final createdPickup = await _service.createPickup(
        scheduleId: scheduleId,
        pickupDate: _pickupDate!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
      );

      final pickupId = _toInt(createdPickup['id']);

      if (pickupId == null) {
        throw Exception(
          'Pickup was created, but its ID was not returned.',
        );
      }

      await _service.assignTruck(
        pickupId: pickupId,
        truckId: vehicleId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Special pickup created successfully.',
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
          _creating = false;
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
          'Create Pickup',
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
            50,
          ),
          children: [
            const Text(
              'Create Upcoming Special Pickup',
              style: TextStyle(
                color: Color(0xFF152033),
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a reusable schedule and create '
              'the actual collection event residents '
              'will be able to join.',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle('Schedule'),

            if (_loadingSchedules)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Color(0xFF008F73),
                  ),
                ),
              )
            else if (_scheduleError != null)
              _errorBox(_scheduleError!)
            else if (_schedules.isEmpty)
              _errorBox(
                'No active schedules are available. '
                'Create a schedule first.',
              )
            else
              DropdownButtonFormField<
                  Map<String, dynamic>>(
                initialValue: _selectedSchedule,
                isExpanded: true,
                decoration: _inputDecoration(
                  'Select schedule',
                  Icons.calendar_month_rounded,
                ),
                items: _schedules.map((schedule) {
                  return DropdownMenuItem<
                      Map<String, dynamic>>(
                    value: schedule,
                    child: Text(
                      _scheduleLabel(schedule),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (schedule) {
                  setState(() {
                    _selectedSchedule = schedule;
                    _pickupDate = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a schedule';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 22),

            if (_selectedSchedule != null)
              _buildScheduleInformation(),

            if (_selectedSchedule != null)
              const SizedBox(height: 26),

            _sectionTitle('Pickup Date'),

            InkWell(
              onTap: _selectedSchedule == null
                  ? null
                  : _selectPickupDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _inputDecoration(
                  'Select pickup date',
                  Icons.event_rounded,
                ),
                child: Text(
                  _pickupDate == null
                      ? 'Choose date'
                      : _formatDate(_pickupDate!),
                  style: TextStyle(
                    color: _pickupDate == null
                        ? const Color(0xFF8290A3)
                        : const Color(0xFF152033),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (_selectedSchedule != null) ...[
              const SizedBox(height: 8),
              Text(
                'Date must be a '
                '${_displayDay(
                  _selectedSchedule!['dayOfWeek']
                          ?.toString() ??
                      '',
                )}.',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 11,
                ),
              ),
            ],

            const SizedBox(height: 26),

            _sectionTitle('Pickup Details'),

            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                'Pickup title',
                Icons.local_shipping_outlined,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter a pickup title';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              decoration: _inputDecoration(
                'Description',
                Icons.description_outlined,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter a description';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration(
                'Pickup location',
                Icons.location_on_outlined,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter a location';
                }

                return null;
              },
            ),

           const SizedBox(height: 26),

          _sectionTitle('Vehicle'),

          if (_loadingVehicles)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Color(0xFF008F73),
                ),
              ),
            )
          else if (_vehicleError != null)
            _errorBox(_vehicleError!)
          else if (_vehicles.isEmpty)
            _errorBox(
              'No available vehicles found. '
              'Please add or make a vehicle available first.',
            )
          else
            DropdownButtonFormField<Map<String, dynamic>>(
              initialValue: _selectedVehicle,
              isExpanded: true,
              decoration: _inputDecoration(
                'Select vehicle',
                Icons.local_shipping_rounded,
              ),
              items: _vehicles.map((vehicle) {
                final registration =
                    vehicle['registrationNumber']
                            ?.toString() ??
                        'Unknown';

                final type =
                    vehicle['vehicleType']
                            ?.toString() ??
                        'Vehicle';

                return DropdownMenuItem<Map<String, dynamic>>(
                  value: vehicle,
                  child: Text(
                    '$registration • $type',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (vehicle) {
                setState(() {
                  _selectedVehicle = vehicle;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a vehicle';
                }

                return null;
              },
            ),

          if (_selectedVehicle != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCBE9E0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFF008F73),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_selectedVehicle!['vehicleType'] ?? 'Vehicle'}'
                      ' • Capacity: '
                      '${_selectedVehicle!['capacity'] ?? '-'}',
                      style: const TextStyle(
                        color: Color(0xFF526477),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _selectedVehicle!['status']
                            ?.toString() ??
                        '',
                    style: const TextStyle(
                      color: Color(0xFF008F73),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 36),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _creating ? null : _createPickup,
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
                icon: _creating
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.add_rounded,
                      ),
                label: Text(
                 _creating
                    ? 'Creating & Assigning...'
                    : 'Create Pickup',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInformation() {
    final schedule = _selectedSchedule!;
    final route = _toMap(schedule['route']);

    final routeName =
        route['routeName']?.toString() ??
            'Unknown Route';

    final area =
        route['areaOrZone']?.toString() ?? '-';

    final day =
        _displayDay(
          schedule['dayOfWeek']?.toString() ?? '',
        );

    final start =
        _displayApiTime(
          schedule['startTime']?.toString() ?? '',
        );

    final end =
        _displayApiTime(
          schedule['endTime']?.toString() ?? '',
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCBE9E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule Information',
            style: TextStyle(
              color: Color(0xFF007C66),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _scheduleInfoRow(
            Icons.route_rounded,
            routeName,
          ),
          const SizedBox(height: 7),
          _scheduleInfoRow(
            Icons.location_on_outlined,
            area,
          ),
          const SizedBox(height: 7),
          _scheduleInfoRow(
            Icons.calendar_today_outlined,
            'Every $day',
          ),
          const SizedBox(height: 7),
          _scheduleInfoRow(
            Icons.schedule_rounded,
            '$start - $end',
          ),
        ],
      ),
    );
  }

  Widget _scheduleInfoRow(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF008F73),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF526477),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

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

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
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

  String _scheduleLabel(
    Map<String, dynamic> schedule,
  ) {
    final route = _toMap(schedule['route']);

    final routeName =
        route['routeName']?.toString() ??
            'Unknown Route';

    final day =
        _displayDay(
          schedule['dayOfWeek']?.toString() ?? '',
        );

    final start =
        _displayApiTime(
          schedule['startTime']?.toString() ?? '',
        );

    return '$routeName • $day • $start';
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '');
  }

  DateTime _nextValidDate() {
    final dayName =
        _selectedSchedule?['dayOfWeek']?.toString();

    if (dayName == null) {
      return DateTime.now();
    }

    var date = DateTime.now();

    for (var i = 0; i < 8; i++) {
      if (_dateMatchesSchedule(date, dayName)) {
        return date;
      }

      date = date.add(const Duration(days: 1));
    }

    return DateTime.now();
  }

  bool _dateMatchesSchedule(
    DateTime date,
    String scheduleDay,
  ) {
    const weekdays = {
      'MONDAY': DateTime.monday,
      'TUESDAY': DateTime.tuesday,
      'WEDNESDAY': DateTime.wednesday,
      'THURSDAY': DateTime.thursday,
      'FRIDAY': DateTime.friday,
      'SATURDAY': DateTime.saturday,
      'SUNDAY': DateTime.sunday,
    };

    return date.weekday ==
        weekdays[scheduleDay.toUpperCase()];
  }

  String _displayDay(String value) {
    if (value.isEmpty) return '-';

    final lower = value.toLowerCase();

    return '${lower[0].toUpperCase()}'
        '${lower.substring(1)}';
  }

  String _displayApiTime(String value) {
    if (value.isEmpty) return '-';

    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour = int.tryParse(parts[0]);

    if (hour == null) {
      return value;
    }

    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';

    var displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}