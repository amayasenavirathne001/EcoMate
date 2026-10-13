import 'package:flutter/material.dart';

import '../../../special_pickup/models/special_pickup.dart';
import '../services/municipal_special_pickup_service.dart';
import 'special_pickup_schedules_screen.dart';

class SpecialPickupsScreen extends StatefulWidget {
  const SpecialPickupsScreen({super.key});

  @override
  State<SpecialPickupsScreen> createState() => _SpecialPickupsScreenState();
}

class _SpecialPickupsScreenState extends State<SpecialPickupsScreen> {
  final MunicipalSpecialPickupService _service =
      MunicipalSpecialPickupService();

  static const Color primary = Color(0xFF008F73);
  static const Color darkText = Color(0xFF152033);

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
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  // ===========================================================
  // LOAD PICKUPS
  // ===========================================================

  Future<void> _loadPickups() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

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

  // ===========================================================
  // MAIN UI
  // ===========================================================

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
            color: darkText,
          ),
        ),
        title: const Text(
          'Special Pickup Management',
          style: TextStyle(
            color: darkText,
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
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPickups,
        color: primary,
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
                    color: primary,
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
                  separatorBuilder: (_, _) =>
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

  // ===========================================================
  // HEADER
  // ===========================================================

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
              color: darkText,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Open pickups from reusable schedules, monitor '
            'resident participation and assign vehicles.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SpecialPickupSchedulesScreen(),
                  ),
                );

                if (changed == true) {
                  await _loadPickups();
                }
              },
              icon: const Icon(
                Icons.calendar_month_rounded,
              ),
              label: const Text('Manage Schedules'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(
                  color: Color(0xFFB7E2D8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // SUMMARY
  // ===========================================================

  Widget _buildSummary() {
    final scheduled =
        _pickups.where((p) => p.status == 'SCHEDULED').length;

    final assigned =
        _pickups.where((p) => p.status == 'ASSIGNED').length;

    final totalJoined = _pickups.fold<int>(
      0,
      (total, pickup) => total + pickup.joinedHouseholds,
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
              color: darkText,
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

  // ===========================================================
  // FILTERS
  // ===========================================================

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
        separatorBuilder: (_, _) => const SizedBox(width: 8),
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
            selectedColor: primary,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? primary
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

  // ===========================================================
  // PICKUP CARD
  // ===========================================================

  Widget _buildPickupCard(SpecialPickup pickup) {
    final isScheduled = pickup.status == 'SCHEDULED';
    final canAssign = pickup.canAssignVehicle;
    final needed = pickup.householdsNeededForMinimum;

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
                  color: primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.title.isEmpty
                          ? 'Special Pickup'
                          : pickup.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(pickup.pickupDate)}'
                      '  •  '
                      '${_formatTime(pickup.startTime)}'
                      ' - ${_formatTime(pickup.endTime)}',
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
                      '${pickup.joinedHouseholds}/${pickup.maxHouseholds}',
                ),
              ),
              Expanded(
                child: _capacityItem(
                  icon: Icons.flag_outlined,
                  title: 'Minimum',
                  value: '${pickup.minHouseholds}',
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
          _participationProgress(pickup),
          if (isScheduled) ...[
            const SizedBox(height: 12),
            _minimumParticipationMessage(pickup),
          ],
          if (pickup.status == 'CANCELLED' &&
              pickup.cancellationReason != null &&
              pickup.cancellationReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _cancellationMessage(pickup.cancellationReason!),
          ],
          const SizedBox(height: 15),
          _truckInformation(pickup),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  _showPickupDetails(pickup);
                },
                child: const Text('View Details'),
              ),
              if (isScheduled)
                OutlinedButton.icon(
                  onPressed: () {
                    _showCancelDialog(pickup);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 17,
                  ),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD94C4C),
                    side: const BorderSide(
                      color: Color(0xFFF0B8B8),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              if (isScheduled)
                ElevatedButton.icon(
                  onPressed: canAssign
                      ? () {
                          _showAssignVehicleDialog(pickup);
                        }
                      : null,
                  icon: Icon(
                    canAssign
                        ? Icons.local_shipping_rounded
                        : Icons.lock_outline_rounded,
                    size: 17,
                  ),
                  label: Text(
                    canAssign
                        ? 'Assign Vehicle'
                        : 'Need $needed More',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFE7ECEB),
                    disabledForegroundColor:
                        const Color(0xFF87938F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF8290A3),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // PARTICIPATION
  // ===========================================================

  Widget _participationProgress(SpecialPickup pickup) {
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
              'Household participation',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF718096),
              ),
            ),
            const Spacer(),
            Text(
              '${pickup.joinedHouseholds}/${pickup.maxHouseholds}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: primary,
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
            backgroundColor: const Color(0xFFE6EFEC),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              Color(0xFF00A786),
            ),
          ),
        ),
      ],
    );
  }

  Widget _minimumParticipationMessage(SpecialPickup pickup) {
    final reached = pickup.minimumParticipationReached;
    final needed = pickup.householdsNeededForMinimum;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: reached
            ? const Color(0xFFE8F7F1)
            : const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: reached
              ? const Color(0xFFBDE5D6)
              : const Color(0xFFF1D9A5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            reached
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            size: 19,
            color: reached
                ? primary
                : const Color(0xFFB97800),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reached
                  ? 'Minimum participation reached '
                      '(${pickup.joinedHouseholds}/${pickup.minHouseholds}). '
                      'A vehicle can now be assigned.'
                  : 'Minimum ${pickup.minHouseholds} households required. '
                      '$needed more ${needed == 1 ? 'household' : 'households'} '
                      'needed before assigning a vehicle.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: reached
                    ? const Color(0xFF14745D)
                    : const Color(0xFF8B620B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancellationMessage(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFF2CCCC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cancel_outlined,
            size: 19,
            color: Color(0xFFD94C4C),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cancellation reason: $reason',
              style: const TextStyle(
                fontSize: 11,
                height: 1.35,
                color: Color(0xFF9B3E3E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // VEHICLE INFORMATION
  // ===========================================================

  Widget _truckInformation(SpecialPickup pickup) {
    final hasTruck = pickup.status == 'ASSIGNED' ||
        pickup.status == 'IN_PROGRESS' ||
        pickup.status == 'COMPLETED';

    return Row(
      children: [
        Icon(
          hasTruck
              ? Icons.local_shipping_rounded
              : Icons.local_shipping_outlined,
          size: 17,
          color: hasTruck
              ? primary
              : const Color(0xFF8A98A8),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            hasTruck
                ? 'Vehicle assigned'
                : 'No vehicle assigned',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasTruck
                  ? primary
                  : const Color(0xFF8A98A8),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // ASSIGN VEHICLE DIALOG
  // ===========================================================

  Future<void> _showAssignVehicleDialog(
    SpecialPickup pickup,
  ) async {
    if (!pickup.canAssignVehicle) {
      _showMessage(
        'Minimum ${pickup.minHouseholds} households are required '
        'before assigning a vehicle.',
        isError: true,
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _AssignVehicleDialog(
          service: _service,
          pickup: pickup,
          onAssigned: () async {
            if (!mounted) return;

            _showMessage('Vehicle assigned successfully.');
            await _loadPickups();
          },
        );
      },
    );
  }

  // ===========================================================
  // CANCEL PICKUP
  // ===========================================================

  Future<void> _showCancelDialog(
    SpecialPickup pickup,
  ) async {
    final reasonController = TextEditingController(
      text: pickup.minimumParticipationReached
          ? ''
          : 'Minimum participation was not reached.',
    );

    var isCancelling = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD94C4C),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Cancel Special Pickup',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 430,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${pickup.joinedHouseholds}/${pickup.minHouseholds} '
                      'minimum households joined',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Cancellation reason',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: reasonController,
                      enabled: !isCancelling,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Enter the reason for cancellation',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCancelling
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: isCancelling
                      ? null
                      : () async {
                          final reason =
                              reasonController.text.trim();

                          if (reason.isEmpty) {
                            _showMessage(
                              'Please enter a cancellation reason.',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() {
                            isCancelling = true;
                          });

                          try {
                            await _service.cancelPickup(
                              pickupId: pickup.id,
                              reason: reason,
                            );

                            if (!mounted ||
                                !dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            _showMessage(
                              'Special pickup cancelled.',
                            );

                            await _loadPickups();
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isCancelling = false;
                            });

                            if (!mounted) return;

                            _showMessage(
                              _cleanError(e),
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFD94C4C),
                    foregroundColor: Colors.white,
                  ),
                  child: isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cancel Pickup'),
                ),
              ],
            );
          },
        );
      },
    );

    reasonController.dispose();
  }

  // ===========================================================
  // STATUS BADGE
  // ===========================================================

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

  // ===========================================================
  // ERROR / EMPTY
  // ===========================================================

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
                color: darkText,
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
                backgroundColor: primary,
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
                color: primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No special pickups found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedFilter == 'ALL'
                  ? 'Open a pickup from Schedules to get started.'
                  : 'There are no '
                      '${_filterLabel(_selectedFilter).toLowerCase()} '
                      'pickups.',
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

  // ===========================================================
  // DETAILS
  // ===========================================================

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
          child: SingleChildScrollView(
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
                          color: darkText,
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
                  'Minimum',
                  '${pickup.minHouseholds} households',
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
                if (pickup.status == 'CANCELLED')
                  _detailRow(
                    'Cancel Reason',
                    pickup.cancellationReason ?? '-',
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

  // ===========================================================
  // HELPERS
  // ===========================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? const Color(0xFFD94C4C) : primary,
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

// =============================================================
// ASSIGN VEHICLE DIALOG
// =============================================================

class _AssignVehicleDialog extends StatefulWidget {
  final MunicipalSpecialPickupService service;
  final SpecialPickup pickup;
  final Future<void> Function() onAssigned;

  const _AssignVehicleDialog({
    required this.service,
    required this.pickup,
    required this.onAssigned,
  });

  @override
  State<_AssignVehicleDialog> createState() =>
      _AssignVehicleDialogState();
}

class _AssignVehicleDialogState
    extends State<_AssignVehicleDialog> {
  List<Map<String, dynamic>> _vehicles = [];
  int? _selectedVehicleId;

  bool _loading = true;
  bool _assigning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await widget.service.getVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _assign() async {
    final vehicleId = _selectedVehicleId;

    if (vehicleId == null) {
      setState(() {
        _error = 'Please select a vehicle.';
      });
      return;
    }

    setState(() {
      _assigning = true;
      _error = null;
    });

    try {
      await widget.service.assignTruck(
        pickupId: widget.pickup.id,
        truckId: vehicleId,
      );

      if (!mounted) return;

      Navigator.pop(context);

      await widget.onAssigned();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _assigning = false;
        _error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.local_shipping_rounded,
            color: Color(0xFF008F73),
          ),
          SizedBox(width: 9),
          Text(
            'Assign Vehicle',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF152033),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF008F73),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pickup.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF152033),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.pickup.joinedHouseholds}/'
                    '${widget.pickup.minHouseholds} '
                    'minimum households joined',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_vehicles.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E8),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No available vehicles found. '
                        'Only active vehicles with AVAILABLE '
                        'status can be assigned.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF8B620B),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _selectedVehicleId,
                      decoration: InputDecoration(
                        labelText: 'Available Vehicle',
                        prefixIcon: const Icon(
                          Icons.local_shipping_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      items: _vehicles.map((vehicle) {
                        final id =
                            (vehicle['id'] as num).toInt();

                        final registration =
                            vehicle['registrationNumber']
                                    ?.toString() ??
                                'Vehicle $id';

                        final type =
                            vehicle['vehicleType']
                                    ?.toString() ??
                                'Vehicle';

                        final capacity =
                            vehicle['capacity'];

                        final capacityText =
                            capacity == null
                                ? ''
                                : ' • $capacity';

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            '$registration • $type'
                            '$capacityText',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _assigning
                          ? null
                          : (value) {
                              setState(() {
                                _selectedVehicleId =
                                    value;
                                _error = null;
                              });
                            },
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFD94C4C),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _assigning
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _loading ||
                  _assigning ||
                  _vehicles.isEmpty
              ? null
              : _assign,
          icon: _assigning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_rounded,
                  size: 18,
                ),
          label: Text(
            _assigning
                ? 'Assigning...'
                : 'Assign Vehicle',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF008F73),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFFE1E7E5),
            disabledForegroundColor:
                const Color(0xFF899490),
          ),
        ),
      ],
    );
  }
}