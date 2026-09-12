import 'package:flutter/material.dart';
import '../../../models/schedule_models.dart';
import '../../../models/recycling_centre.dart';
import '../../../models/waste_category.dart';
import '../../../services/schedule_service.dart';
import '../../../services/recycling_service.dart';
import '../theme/municipal_colors.dart';
import 'create_schedule_page.dart';
import 'route_management_page.dart';

class MunicipalSchedulePage extends StatefulWidget {
  final Function(int)? onTabChange;

  const MunicipalSchedulePage({super.key, this.onTabChange});

  @override
  State<MunicipalSchedulePage> createState() => _MunicipalSchedulePageState();
}

class _MunicipalSchedulePageState extends State<MunicipalSchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();
  final RecyclingService _recyclingService = RecyclingService();

  List<CollectionScheduleModel> _allSchedules = [];
  List<RouteModel> _routes = [];
  List<WasteCategory> _categories = [];

  bool _isLoading = true;
  String? _errorMessage;

  // View state: 'list' or 'calendar'
  String _viewType = 'list';

  // Filters
  String _statusFilter = 'All'; // All, Active, Inactive, Today, Upcoming
  RouteModel? _routeFilter;
  String? _zoneFilter;
  WasteCategory? _categoryFilter;

  // Horizontal Calendar date selection
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _categories = _recyclingService.getWasteCategories();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _scheduleService.getSchedules();
      final routes = await _scheduleService.getRoutes();
      setState(() {
        _allSchedules = schedules;
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load schedules. Please make sure backend is running.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleScheduleStatus(CollectionScheduleModel schedule) async {
    final newStatus = schedule.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await _scheduleService.updateScheduleStatus(schedule.id!, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule "${schedule.scheduleName}" set to $newStatus'),
          backgroundColor: MunicipalColors.success,
        ),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update schedule status'),
          backgroundColor: MunicipalColors.error,
        ),
      );
    }
  }

  List<CollectionScheduleModel> _getFilteredSchedules() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return _allSchedules.where((s) {
      // 1. Status Filter
      if (_statusFilter == 'Active' && s.status != 'ACTIVE') return false;
      if (_statusFilter == 'Inactive' && s.status != 'INACTIVE') return false;

      if (_statusFilter == 'Today') {
        // Daily is today. Weekly checks day of week. Or exact date match.
        if (s.frequency == 'Daily') {
          // OK
        } else if (s.frequency == 'Weekly') {
          // Matches weekday (e.g. "Tuesday")
          final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          final todayDayName = weekdays[now.weekday - 1];
          if (s.collectionDateOrDay != todayDayName) return false;
        } else {
          // One Time or Custom (exact date)
          if (s.collectionDateOrDay != todayStr) return false;
        }
      }

      if (_statusFilter == 'Upcoming') {
        // Only show future/upcoming one time schedules or active recurring
        if (s.status != 'ACTIVE') return false;
      }

      // 2. Calendar Selection (only filters if in calendar view)
      if (_viewType == 'calendar') {
        final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
        if (s.frequency == 'Daily') {
          // Daily runs everyday
        } else if (s.frequency == 'Weekly') {
          final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          final selectedDayName = weekdays[_selectedDate.weekday - 1];
          if (s.collectionDateOrDay != selectedDayName) return false;
        } else {
          if (s.collectionDateOrDay != dateStr) return false;
        }
      }

      // 3. Optional Filters
      if (_routeFilter != null && s.routeId != _routeFilter!.id) return false;
      if (_zoneFilter != null && _zoneFilter!.isNotEmpty && !s.areaOrZone.toLowerCase().contains(_zoneFilter!.toLowerCase())) return false;
      if (_categoryFilter != null && s.wasteCategoryId != _categoryFilter!.id) return false;

      return true;
    }).toList();
  }

  void _showRecyclingCentreDetails(RecyclingCentre centre) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: MunicipalColors.pageBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(centre.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoRow(Icons.location_on, 'Address', centre.address),
                _infoRow(Icons.location_city, 'City', centre.city),
                _infoRow(Icons.phone, 'Contact', centre.contactNumber),
                _infoRow(Icons.access_time, 'Hours', centre.operatingHours),
                _infoRow(Icons.check_circle_outline, 'Status', centre.isOpen ? 'Open' : 'Closed'),
                const SizedBox(height: 12),
                const Text('Accepted Materials:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 6,
                  children: centre.acceptedMaterials.map((m) => Chip(label: Text(m, style: const TextStyle(fontSize: 11)))).toList(),
                )
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: MunicipalColors.secondaryGreen),
          const SizedBox(width: 8),
          Expanded(child: Text('$label: $value', style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _getFilteredSchedules();

    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        title: const Text(
          "Collection Schedules",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.route_outlined, color: MunicipalColors.secondaryGreen),
            tooltip: 'Route Management',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RouteManagementPage()),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(backgroundColor: MunicipalColors.secondaryGreen),
                          child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header / Controls Panel
                    Container(
                      color: MunicipalColors.primaryBg,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // View Selector
                              ToggleButtons(
                                borderRadius: BorderRadius.circular(8),
                                selectedColor: Colors.white,
                                fillColor: MunicipalColors.secondaryGreen,
                                color: MunicipalColors.secondaryText,
                                constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
                                isSelected: [_viewType == 'list', _viewType == 'calendar'],
                                onPressed: (index) {
                                  setState(() {
                                    _viewType = index == 0 ? 'list' : 'calendar';
                                  });
                                },
                                children: const [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Icon(Icons.list, size: 18), SizedBox(width: 4), Text('List')],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Icon(Icons.calendar_month, size: 18), SizedBox(width: 4), Text('Calendar')],
                                  ),
                                ],
                              ),
                              // Create Schedule button
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CreateSchedulePage()),
                                  ).then((value) {
                                    if (value == true) _loadData();
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                                label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MunicipalColors.secondaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Horizontal Calendar Strip if viewType is calendar
                          if (_viewType == 'calendar') ...[
                            _buildCalendarStrip(),
                            const SizedBox(height: 8),
                          ],

                          // Status Filter chips (Only for List view)
                          if (_viewType == 'list')
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['All', 'Active', 'Inactive', 'Today', 'Upcoming'].map((filter) {
                                  final isSelected = _statusFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: ChoiceChip(
                                      label: Text(filter),
                                      selected: isSelected,
                                      selectedColor: MunicipalColors.secondaryGreen,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : MunicipalColors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _statusFilter = filter;
                                          });
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Advanced optional filters (Route, Zone, Waste Category)
                    _buildOptionalFiltersPanel(),

                    // Schedules List
                    Expanded(
                      child: filteredSchedules.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _viewType == 'calendar' ? Icons.event_busy_outlined : Icons.calendar_today_outlined,
                                    size: 64,
                                    color: MunicipalColors.secondaryText,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No schedules found matching criteria.',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _statusFilter = 'All';
                                        _routeFilter = null;
                                        _zoneFilter = null;
                                        _categoryFilter = null;
                                      });
                                    },
                                    child: const Text('Reset Filters', style: TextStyle(color: MunicipalColors.secondaryGreen)),
                                  )
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredSchedules.length,
                              itemBuilder: (context, index) {
                                final schedule = filteredSchedules[index];
                                final isNotAssigned = schedule.resourceStatus == 'Not Assigned';

                                // Find waste category details for styling
                                final wasteCat = _categories.firstWhere(
                                  (c) => c.id == schedule.wasteCategoryId,
                                  orElse: () => WasteCategory(
                                    id: 'other',
                                    name: schedule.wasteCategoryId,
                                    binColorName: 'Grey',
                                    binColor: Colors.grey,
                                    icon: Icons.restore_from_trash,
                                    description: '',
                                    isRecyclable: false,
                                    commonItems: [],
                                    preparationSteps: [],
                                    dos: [],
                                    donts: [],
                                  ),
                                );

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: MunicipalColors.border),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title and actions
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    schedule.scheduleName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: MunicipalColors.primaryText,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${schedule.route?.routeCode ?? "Route"} – ${schedule.route?.routeName ?? "No Route"}',
                                                    style: const TextStyle(
                                                      color: MunicipalColors.secondaryGreen,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, color: MunicipalColors.secondaryText, size: 20),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => CreateSchedulePage(scheduleToEdit: schedule),
                                                      ),
                                                    ).then((value) {
                                                      if (value == true) _loadData();
                                                    });
                                                  },
                                                ),
                                                Switch(
                                                  value: schedule.status == 'ACTIVE',
                                                  activeColor: MunicipalColors.secondaryGreen,
                                                  onChanged: (_) => _toggleScheduleStatus(schedule),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 20, color: MunicipalColors.border),

                                        // Schedule info
                                        _cardInfoRow(Icons.location_city, 'Zone', schedule.areaOrZone),
                                        _cardInfoRow(
                                          wasteCat.icon,
                                          'Waste Category',
                                          wasteCat.name,
                                          iconColor: wasteCat.binColor,
                                        ),
                                        _cardInfoRow(
                                          Icons.calendar_month,
                                          'Schedule',
                                          '${schedule.frequency} – ${schedule.collectionDateOrDay}',
                                        ),
                                        _cardInfoRow(
                                          Icons.access_time,
                                          'Timing',
                                          '${schedule.startTime} – ${schedule.endTime}',
                                        ),
                                        _cardInfoRow(
                                          Icons.navigation,
                                          'Destination',
                                          schedule.destinationType == 'Recycling Centre' && schedule.recyclingCenter != null
                                              ? schedule.recyclingCenter!.name
                                              : 'Municipal Disposal Site',
                                          trailing: schedule.destinationType == 'Recycling Centre' && schedule.recyclingCenter != null
                                              ? GestureDetector(
                                                  onTap: () => _showRecyclingCentreDetails(schedule.recyclingCenter!),
                                                  child: const Icon(Icons.info_outline, size: 16, color: MunicipalColors.secondaryGreen),
                                                )
                                              : null,
                                        ),

                                        const SizedBox(height: 12),

                                        // Status & Resource Assignment button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isNotAssigned ? MunicipalColors.warning.withOpacity(0.15) : MunicipalColors.success.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isNotAssigned ? Icons.warning_amber_rounded : Icons.check_circle,
                                                    size: 14,
                                                    color: isNotAssigned ? Colors.orange.shade800 : MunicipalColors.success,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isNotAssigned ? 'Resources: Not Assigned' : 'Resources: Assigned',
                                                    style: TextStyle(
                                                      color: isNotAssigned ? Colors.orange.shade800 : MunicipalColors.secondaryGreen,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isNotAssigned)
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Navigate to the existing Operations Coordination page
                                                  if (widget.onTabChange != null) {
                                                    widget.onTabChange!(1); // index 1 corresponds to OperationsPage in MunicipalBottomNav
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: MunicipalColors.secondaryGreen,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                child: const Text(
                                                  'Assign Resources',
                                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _cardInfoRow(IconData icon, String label, String value, {Color? iconColor, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? MunicipalColors.secondaryText),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.secondaryText, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: MunicipalColors.primaryText, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    // Generate dates for current week (Mon-Sun)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = monday.add(Duration(days: index));
        final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
        final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? MunicipalColors.secondaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.border),
            ),
            child: Column(
              children: [
                Text(
                  weekdays[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : MunicipalColors.secondaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : MunicipalColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOptionalFiltersPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText, fontSize: 14)),
        leading: const Icon(Icons.filter_list, color: MunicipalColors.secondaryGreen, size: 20),
        dense: true,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<RouteModel>(
                  isExpanded: true,
                  value: _routeFilter,
                  hint: const Text('Route'),
                  items: [
                    const DropdownMenuItem<RouteModel>(value: null, child: Text('All Routes')),
                    ..._routes.map((r) => DropdownMenuItem(value: r, child: Text(r.routeCode))),
                  ],
                  onChanged: (val) => setState(() => _routeFilter = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<WasteCategory>(
                  isExpanded: true,
                  value: _categoryFilter,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem<WasteCategory>(value: null, child: Text('All Categories')),
                    ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                  ],
                  onChanged: (val) => setState(() => _categoryFilter = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Filter by Area/Zone Name',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (val) => setState(() => _zoneFilter = val.trim()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
