import 'package:flutter/material.dart';

import '../../../special_pickup/models/special_pickup.dart';
import '../services/municipal_special_pickup_service.dart';

class SpecialPickupsScreen extends StatefulWidget {
  const SpecialPickupsScreen({super.key});

  @override
  State<SpecialPickupsScreen> createState() =>
      _SpecialPickupsScreenState();
}

class _SpecialPickupsScreenState extends State<SpecialPickupsScreen> {
  final MunicipalSpecialPickupService _service =
      MunicipalSpecialPickupService();

  List<SpecialPickup> _pickups = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'ALL';

  final List<String> _filters = [
    'ALL',
    'SCHEDULED',
    'ASSIGNED',
    'FULL',
    'IN_PROGRESS',
    'COMPLETED',
  ];

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pickups = await _service.getPickups();

      if (!mounted) return;

      pickups.sort(
        (a, b) => b.pickupDate.compareTo(a.pickupDate),
      );

      setState(() {
        _pickups = pickups;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(e);
        _isLoading = false;
      });
    }
  }

  List<SpecialPickup> get _filteredPickups {
    if (_selectedFilter == 'ALL') {
      return _pickups;
    }

    return _pickups
        .where((pickup) => pickup.status == _selectedFilter)
        .toList();
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
          'Special Pickup Management',
          style: TextStyle(
            color: Color(0xFF152033),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadPickups,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF008F73),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPickups,
        color: const Color(0xFF008F73),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildSummary(),
            ),
            SliverToBoxAdapter(
              child: _buildFilters(),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF008F73),
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(),
              )
            else if (_filteredPickups.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  30,
                ),
                sliver: SliverList.separated(
                  itemCount: _filteredPickups.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _buildPickupCard(
                      _filteredPickups[index],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Special Pickups',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF152033),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Create, monitor and assign municipal special '
            'waste collections.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showComingSoon('Manage Schedules');
                  },
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: const Text('Schedules'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF008F73),
                    side: const BorderSide(
                      color: Color(0xFFB7E2D8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showComingSoon(
                      'Create Special Pickup',
                    );
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text('Create Pickup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF008F73),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final scheduled = _pickups
        .where((p) => p.status == 'SCHEDULED')
        .length;

    final assigned = _pickups
        .where((p) => p.status == 'ASSIGNED')
        .length;

    final totalJoined = _pickups.fold<int>(
      0,
      (total, pickup) =>
          total + pickup.joinedHouseholds,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              icon: Icons.local_shipping_rounded,
              value: '${_pickups.length}',
              label: 'Total',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              icon: Icons.schedule_rounded,
              value: '$scheduled',
              label: 'Scheduled',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              icon: Icons.check_circle_outline_rounded,
              value: '$assigned',
              label: 'Assigned',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              icon: Icons.people_alt_outlined,
              value: '$totalJoined',
              label: 'Joined',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4ECE9),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF00977A),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF152033),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return ChoiceChip(
            label: Text(_filterLabel(filter)),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: const Color(0xFF008F73),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(0xFF008F73)
                  : const Color(0xFFE0E8E5),
            ),
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF5D6B7E),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickupCard(SpecialPickup pickup) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3ECE9),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F5EF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF008F73),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.title.isEmpty
                          ? 'Special Pickup'
                          : pickup.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF152033),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(pickup.pickupDate)}'
                      '  •  '
                      '${_formatTime(pickup.startTime)}'
                      ' - '
                      '${_formatTime(pickup.endTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(pickup.status),
            ],
          ),
          const SizedBox(height: 15),
          _infoRow(
            Icons.location_on_outlined,
            _locationText(pickup),
          ),
          if (pickup.acceptedWasteTypes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.recycling_rounded,
              pickup.acceptedWasteTypes.join(', '),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            color: Color(0xFFEDF1F0),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _capacityItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Households',
                  value:
                      '${pickup.joinedHouseholds}'
                      '/${pickup.maxHouseholds}',
                ),
              ),
              Expanded(
                child: _capacityItem(
                  icon: Icons.scale_outlined,
                  title: 'Weight',
                  value:
                      '${_number(pickup.currentEstimatedWeightKg)}'
                      '/${_number(pickup.maxWeightKg)} kg',
                ),
              ),
              Expanded(
                child: _capacityItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Volume',
                  value:
                      '${_number(pickup.currentEstimatedVolumeM3)}'
                      '/${_number(pickup.maxVolumeM3)} m³',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _capacityProgress(pickup),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _truckInformation(pickup),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  _showPickupDetails(pickup);
                },
                child: const Text('View Details'),
              ),
              if (pickup.status == 'SCHEDULED')
                ElevatedButton(
                  onPressed: () {
                    _showComingSoon('Assign Truck');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF008F73),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Assign'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF00977A),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF5F6D7E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _capacityItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF00977A),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF152033),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8290A3),
          ),
        ),
      ],
    );
  }

  Widget _capacityProgress(SpecialPickup pickup) {
    final max = pickup.maxHouseholds;

    double progress = 0;

    if (max > 0) {
      progress = pickup.joinedHouseholds / max;
    }

    progress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Household capacity',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF718096),
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF008F73),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor:
                const Color(0xFFE6EFEC),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              Color(0xFF00A786),
            ),
          ),
        ),
      ],
    );
  }

  Widget _truckInformation(SpecialPickup pickup) {
    final hasTruck = pickup.status == 'ASSIGNED';

    return Row(
      children: [
        Icon(
          hasTruck
              ? Icons.local_shipping_rounded
              : Icons.local_shipping_outlined,
          size: 17,
          color: hasTruck
              ? const Color(0xFF008F73)
              : const Color(0xFF8A98A8),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            hasTruck
                ? 'Truck assigned'
                : 'No truck assigned',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasTruck
                  ? const Color(0xFF008F73)
                  : const Color(0xFF8A98A8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color background;
    Color foreground;

    switch (status) {
      case 'ASSIGNED':
        background = const Color(0xFFDDF5E9);
        foreground = const Color(0xFF16865D);
        break;

      case 'SCHEDULED':
        background = const Color(0xFFE7EEFF);
        foreground = const Color(0xFF3C6ED8);
        break;

      case 'FULL':
        background = const Color(0xFFFFE8D9);
        foreground = const Color(0xFFE46F21);
        break;

      case 'IN_PROGRESS':
        background = const Color(0xFFFFF1CC);
        foreground = const Color(0xFFB27B00);
        break;

      case 'COMPLETED':
        background = const Color(0xFFE4F5EE);
        foreground = const Color(0xFF16865D);
        break;

      case 'CANCELLED':
        background = const Color(0xFFFFE4E4);
        foreground = const Color(0xFFD94C4C);
        break;

      default:
        background = const Color(0xFFEDF1F5);
        foreground = const Color(0xFF637083);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _filterLabel(status),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Color(0xFF9AA7B6),
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load special pickups',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF152033),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadPickups,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF008F73),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F5F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 37,
                color: Color(0xFF008F73),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No special pickups found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF152033),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedFilter == 'ALL'
                  ? 'Create a special pickup to get started.'
                  : 'There are no ${_filterLabel(_selectedFilter).toLowerCase()} pickups.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickupDetails(SpecialPickup pickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE3E1),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pickup.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF152033),
                        ),
                      ),
                    ),
                    _statusBadge(pickup.status),
                  ],
                ),
                const SizedBox(height: 18),
                _detailRow(
                  'Date',
                  _formatDate(pickup.pickupDate),
                ),
                _detailRow(
                  'Time',
                  '${_formatTime(pickup.startTime)} - '
                  '${_formatTime(pickup.endTime)}',
                ),
                _detailRow(
                  'Location',
                  pickup.location,
                ),
                _detailRow(
                  'Service Area',
                  pickup.serviceArea,
                ),
                _detailRow(
                  'Households',
                  '${pickup.joinedHouseholds} / '
                  '${pickup.maxHouseholds}',
                ),
                _detailRow(
                  'Weight',
                  '${_number(pickup.currentEstimatedWeightKg)}'
                  ' / ${_number(pickup.maxWeightKg)} kg',
                ),
                _detailRow(
                  'Volume',
                  '${_number(pickup.currentEstimatedVolumeM3)}'
                  ' / ${_number(pickup.maxVolumeM3)} m³',
                ),
                _detailRow(
                  'Waste Types',
                  pickup.acceptedWasteTypes.join(', '),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8290A3),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Color(0xFF273548),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be connected next.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _locationText(SpecialPickup pickup) {
    if (pickup.location.isNotEmpty &&
        pickup.serviceArea.isNotEmpty) {
      return '${pickup.location} • ${pickup.serviceArea}';
    }

    if (pickup.location.isNotEmpty) {
      return pickup.location;
    }

    if (pickup.serviceArea.isNotEmpty) {
      return pickup.serviceArea;
    }

    return 'Location not specified';
  }

  String _filterLabel(String value) {
    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}'
                  '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
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

  String _number(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}