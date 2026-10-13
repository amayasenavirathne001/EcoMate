import 'package:flutter/material.dart';

import '../services/municipal_special_pickup_service.dart';
import 'create_special_pickup_schedule_screen.dart';

class SpecialPickupSchedulesScreen extends StatefulWidget {
  const SpecialPickupSchedulesScreen({super.key});

  @override
  State<SpecialPickupSchedulesScreen> createState() =>
      _SpecialPickupSchedulesScreenState();
}

class _SpecialPickupSchedulesScreenState
    extends State<SpecialPickupSchedulesScreen> {
  static const Color _primary = Color(0xFF008F73);
  static const Color _dark = Color(0xFF152033);
  static const Color _muted = Color(0xFF718096);
  static const Color _background = Color(0xFFF6F9F8);

  final MunicipalSpecialPickupService _service =
      MunicipalSpecialPickupService();

  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _service.getSchedules();

      if (!mounted) return;

      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _disableSchedule(
    Map<String, dynamic> schedule,
  ) async {
    final id = _int(schedule['id']);

    if (id == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD94C4C),
              ),
              SizedBox(width: 10),
              Text('Disable Schedule?'),
            ],
          ),
          content: const Text(
            'This schedule will no longer be available '
            'for opening future special pickups.',
            style: TextStyle(
              color: _muted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94C4C),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Disable'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _service.disableSchedule(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule disabled successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _loadSchedules();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showOpenPickupDialog(
    Map<String, dynamic> schedule,
  ) async {
    final scheduleId = _int(schedule['id']);
    final route = _map(schedule['route']);

    final routeName = _text(
      route['routeName'],
      'Special Pickup Route',
    );

    final area = _text(
      route['areaOrZone'],
      'Area not specified',
    );

    final dayRaw = _text(schedule['dayOfWeek'], '');
    final day = _formatDay(dayRaw);

    final startTime = _formatTime(
      _text(schedule['startTime'], ''),
    );

    final endTime = _formatTime(
      _text(schedule['endTime'], ''),
    );

    final maxHouseholds = _int(schedule['maxHouseholds']);

    DateTime? selectedDate;
    bool isOpening = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> selectDate() async {
              final now = DateTime.now();

              final firstDate = DateTime(
                now.year,
                now.month,
                now.day,
              );

              final initialDate = _nextMatchingDay(
                firstDate,
                dayRaw,
              );

              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: firstDate.add(
                  const Duration(days: 365),
                ),
                helpText: 'SELECT PICKUP DATE',
                cancelText: 'CANCEL',
                confirmText: 'SELECT',
              );

              if (picked == null) return;

              final selectedDay =
                  _dayName(picked.weekday);

              if (selectedDay.toUpperCase() !=
                  dayRaw.toUpperCase()) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please select a $day. '
                      'This schedule runs every $day.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                return;
              }

              setDialogState(() {
                selectedDate = picked;
              });
            }

            Future<void> openPickup() async {
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please select a pickup date first.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              setDialogState(() {
                isOpening = true;
              });

              try {
                await _service.createPickup(
                  scheduleId: scheduleId,
                  pickupDate: selectedDate!,
                  title: '$routeName Special Pickup',
                  description:
                      'Special pickup for $routeName.',
                  location: area,
                );

                if (!mounted || !dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Special pickup opened successfully.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isOpening = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20,
              ),
              title: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  18,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6F2),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: _primary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Special Pickup',
                            style: TextStyle(
                              color: _dark,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Publish this pickup for residents',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: 430,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    18,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ROUTE',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        routeName,
                        style: const TextStyle(
                          color: _dark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: _primary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              area,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAF9),
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE4ECE9),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _dialogInfo(
                                Icons.calendar_today_outlined,
                                'Schedule',
                                'Every $day',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color:
                                  const Color(0xFFE0E8E6),
                            ),
                            Expanded(
                              child: _dialogInfo(
                                Icons.schedule_rounded,
                                'Time',
                                '$startTime - $endTime',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color:
                                  const Color(0xFFE0E8E6),
                            ),
                            Expanded(
                              child: _dialogInfo(
                                Icons.people_outline_rounded,
                                'Capacity',
                                '$maxHouseholds homes',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Pickup Date',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Choose a $day for this pickup.',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap:
                            isOpening ? null : selectDate,
                        borderRadius:
                            BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: selectedDate == null
                                ? Colors.white
                                : const Color(0xFFF0FAF7),
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedDate == null
                                  ? const Color(0xFFD9E3E0)
                                  : _primary,
                              width: selectedDate == null
                                  ? 1
                                  : 1.4,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE8F6F2,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .calendar_month_rounded,
                                  color: _primary,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? 'Select pickup date'
                                          : _dateForDisplay(
                                              selectedDate!,
                                            ),
                                      style: TextStyle(
                                        color:
                                            selectedDate ==
                                                    null
                                                ? _muted
                                                : _dark,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    if (selectedDate !=
                                        null) ...[
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        day,
                                        style:
                                            const TextStyle(
                                          color: _primary,
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                                size: 14,
                                color: Color(0xFF9AA7B5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E8),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Color(0xFFB7791F),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'After opening, this pickup '
                                'will have SCHEDULED status '
                                'and residents can join it.',
                                style: TextStyle(
                                  color: Color(0xFF8A651C),
                                  fontSize: 11,
                                  height: 1.4,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isOpening
                      ? null
                      : () =>
                          Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      isOpening ? null : openPickup,
                  icon: isOpening
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.publish_rounded,
                          size: 18,
                        ),
                  label: Text(
                    isOpening
                        ? 'Opening...'
                        : 'Open Pickup',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _primary.withValues(alpha: 0.55),
                    disabledForegroundColor:
                        Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _dark,
          ),
        ),
        title: const Text(
          'Special Pickup Schedules',
          style: TextStyle(
            color: _dark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadSchedules,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _primary,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const CreateSpecialPickupScheduleScreen(),
            ),
          );

          if (created == true) {
            await _loadSchedules();
          }
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Schedule',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchedules,
        color: _primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.symmetric(
              horizontal: 120,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: Color(0xFFD94C4C),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Unable to load schedules',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadSchedules,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (_schedules.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 38,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No active schedules',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Create a reusable route schedule to '
            'start opening special pickups.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        100,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Schedules',
                    style: TextStyle(
                      color: _dark,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Choose a schedule and open an '
                    'upcoming pickup for residents.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_schedules.length} Active',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        ..._schedules.map(
          (schedule) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildScheduleCard(schedule),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
    Map<String, dynamic> schedule,
  ) {
    final route = _map(schedule['route']);

    final routeName =
        _text(route['routeName'], 'Unknown Route');

    final routeCode =
        _text(route['routeCode'], '');

    final area =
        _text(route['areaOrZone'], 'Area not specified');

    final day =
        _formatDay(_text(schedule['dayOfWeek'], ''));

    final startTime =
        _formatTime(_text(schedule['startTime'], ''));

    final endTime =
        _formatTime(_text(schedule['endTime'], ''));

    final maxHouseholds =
        _int(schedule['maxHouseholds']);

    final maxWeight =
        _double(schedule['maxWeightKg']);

    final maxVolume =
        _double(schedule['maxVolumeM3']);

    final deadline =
        _int(schedule['joinDeadlineHours']);

    final wasteTypes =
        _text(schedule['acceptedWasteTypes'], '');

    final active = schedule['active'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1EAE7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              17,
              17,
              17,
              15,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6F2),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: _primary,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            routeName,
                            style: const TextStyle(
                              color: _dark,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          if (routeCode.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              routeCode,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _statusBadge(active),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRow(
                  Icons.location_on_outlined,
                  area,
                ),
                const SizedBox(height: 9),
                _infoRow(
                  Icons.calendar_today_outlined,
                  'Every $day',
                ),
                const SizedBox(height: 9),
                _infoRow(
                  Icons.schedule_rounded,
                  '$startTime - $endTime',
                ),
                const SizedBox(height: 17),
                const Divider(
                  height: 1,
                  color: Color(0xFFEDF1F0),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CAPACITY',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF9),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _capacityItem(
                          Icons.people_alt_outlined,
                          '$maxHouseholds',
                          'Households',
                        ),
                      ),
                      _smallDivider(),
                      Expanded(
                        child: _capacityItem(
                          Icons.scale_outlined,
                          '${_number(maxWeight)} kg',
                          'Weight',
                        ),
                      ),
                      _smallDivider(),
                      Expanded(
                        child: _capacityItem(
                          Icons.inventory_2_outlined,
                          '${_number(maxVolume)} m³',
                          'Volume',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 17,
                      color: _primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Join closes $deadline hours '
                        'before pickup.',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (wasteTypes.isNotEmpty) ...[
                  const SizedBox(height: 11),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.recycling_rounded,
                        size: 17,
                        color: _primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          wasteTypes
                              .split(',')
                              .map((e) => e.trim())
                              .join(' • '),
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              12,
              10,
              12,
              10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFCFC),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFEDF1F0),
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: active
                      ? () =>
                          _disableSchedule(schedule)
                      : null,
                  icon: const Icon(
                    Icons.block_rounded,
                    size: 17,
                  ),
                  label: const Text('Disable'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color(0xFFD94C4C),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: active
                      ? () =>
                          _showOpenPickupDialog(
                            schedule,
                          )
                      : null,
                  icon: const Icon(
                    Icons.publish_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Open Pickup',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFD9E3E0),
                    disabledForegroundColor:
                        const Color(0xFF8A9794),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: _primary,
          size: 19,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _dark,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: _primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5F6D7E),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _capacityItem(
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: _primary,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _dark,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8290A3),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _smallDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE4ECE9),
    );
  }

  Widget _statusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFDDF5E9)
            : const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF16865D)
                  : const Color(0xFF8290A3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(
              color: active
                  ? const Color(0xFF16865D)
                  : const Color(0xFF637083),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  int _int(dynamic value) {
    if (value is int) return value;

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double _double(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _number(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _formatDay(String day) {
    if (day.isEmpty) return '-';

    final lower = day.toLowerCase();

    return '${lower[0].toUpperCase()}'
        '${lower.substring(1)}';
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '-';

    final parts = time.split(':');

    if (parts.length < 2) {
      return time;
    }

    final hour = int.tryParse(parts[0]);

    if (hour == null) {
      return time;
    }

    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';

    var displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour:$minute $period';
  }



  String _dateForDisplay(DateTime date) {
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

  String _dayName(int weekday) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];

    return days[weekday - 1];
  }

  DateTime _nextMatchingDay(
    DateTime from,
    String requiredDay,
  ) {
    DateTime candidate = from;

    for (var i = 0; i < 7; i++) {
      if (_dayName(candidate.weekday) ==
          requiredDay.toUpperCase()) {
        return candidate;
      }

      candidate =
          candidate.add(const Duration(days: 1));
    }

    return from;
  }
}