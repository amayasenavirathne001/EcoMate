import 'package:flutter/material.dart';

import '../models/special_pickup.dart';
import '../services/special_pickup_service.dart';

class AvailableSpecialPickupsScreen extends StatefulWidget {
  const AvailableSpecialPickupsScreen({super.key});

  @override
  State<AvailableSpecialPickupsScreen> createState() =>
      _AvailableSpecialPickupsScreenState();
}

class _AvailableSpecialPickupsScreenState
    extends State<AvailableSpecialPickupsScreen> {
  final SpecialPickupService _service = SpecialPickupService();

  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color background = Color(0xFFFAFCFA);
  static const Color darkText = Color(0xFF071A26);
  static const Color cancelledRed = Color(0xFFC62828);

  List<SpecialPickup> _pickups = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final pickups = await _service.getAvailablePickups();

      pickups.sort(
        (a, b) => a.pickupDate.compareTo(b.pickupDate),
      );

      if (!mounted) return;

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
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _pickups;
    }

    return _pickups.where((pickup) {
      return pickup.title.toLowerCase().contains(query) ||
          pickup.location.toLowerCase().contains(query) ||
          pickup.serviceArea.toLowerCase().contains(query) ||
          pickup.status.toLowerCase().contains(query) ||
          pickup.acceptedWasteTypes
              .join(' ')
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: darkText,
        ),
        title: const Text(
          'Available Special Pickups',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: _loadPickups,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off_rounded,
            size: 60,
            color: Color(0xFF9AA7A0),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load special pickups',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF718078),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadPickups,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    final pickups = _filteredPickups;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        const Text(
          'View upcoming special waste collections '
          'and updates from your municipality.',
          style: TextStyle(
            color: Color(0xFF66766E),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),

        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search special pickups...',
            prefixIcon: const Icon(
              Icons.search_rounded,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE3EAE6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: primaryGreen,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        if (pickups.isEmpty)
          _buildEmptyState()
        else
          ...pickups.map(
            (pickup) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildPickupCard(pickup),
            ),
          ),
      ],
    );
  }

  Widget _buildPickupCard(SpecialPickup pickup) {
    final remaining =
        pickup.maxHouseholds - pickup.joinedHouseholds;

    final bool cancelled = pickup.isCancelled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cancelled
              ? const Color(0xFFFFCCCC)
              : const Color(0xFFE1EAE5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
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
                  color: cancelled
                      ? const Color(0xFFFFEAEA)
                      : const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  cancelled
                      ? Icons.cancel_outlined
                      : Icons.local_shipping_rounded,
                  color: cancelled
                      ? cancelledRed
                      : primaryGreen,
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
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_formatDate(pickup.pickupDate)}'
                      ' • '
                      '${_formatTime(pickup.startTime)}'
                      ' - ${_formatTime(pickup.endTime)}',
                      style: const TextStyle(
                        color: Color(0xFF718078),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(pickup),
            ],
          ),

          const SizedBox(height: 15),

          _infoRow(
            Icons.location_on_outlined,
            _locationText(pickup),
            color: cancelled
                ? cancelledRed
                : primaryGreen,
          ),

          if (pickup.acceptedWasteTypes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.recycling_rounded,
              pickup.acceptedWasteTypes.join(', '),
              color: cancelled
                  ? cancelledRed
                  : primaryGreen,
            ),
          ],

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _smallInfo(
                  'Joined',
                  '${pickup.joinedHouseholds}'
                      '/${pickup.maxHouseholds}',
                ),
              ),
              Expanded(
                child: _smallInfo(
                  'Available',
                  '${remaining < 0 ? 0 : remaining}',
                ),
              ),
              Expanded(
                child: _smallInfo(
                  'Weight Left',
                  '${_number(pickup.remainingWeightKg)} kg',
                ),
              ),
              Expanded(
                child: _smallInfo(
                  'Volume Left',
                  '${_number(pickup.remainingVolumeM3)} m³',
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (cancelled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: cancelledRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cancelled: ${_cancellationReason(pickup)}',
                      style: const TextStyle(
                        color: Color(0xFF8F3030),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Expanded(
                child: Text(
                  _cardStatusText(pickup),
                  style: TextStyle(
                    color: cancelled
                        ? cancelledRed
                        : pickup.hasJoinRequest
                            ? primaryGreen
                            : const Color(0xFF66766E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  _showPickupDetails(pickup);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cancelled
                      ? const Color(0xFF5F6B65)
                      : primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  cancelled || pickup.hasJoinRequest
                      ? 'View'
                      : 'View & Join',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(SpecialPickup pickup) {
    String text;
    Color backgroundColor;
    Color foregroundColor;

    if (pickup.isCancelled) {
      text = 'CANCELLED';
      backgroundColor = const Color(0xFFFFE5E5);
      foregroundColor = cancelledRed;
    } else if (pickup.isApproved) {
      text = 'JOINED';
      backgroundColor = const Color(0xFFE4F5E9);
      foregroundColor = primaryGreen;
    } else if (pickup.isPending) {
      text = 'PENDING';
      backgroundColor = const Color(0xFFFFF2D8);
      foregroundColor = const Color(0xFFA96D00);
    } else {
      text = 'OPEN';
      backgroundColor = const Color(0xFFE8F5EB);
      foregroundColor = primaryGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text, {
    Color color = primaryGreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: color,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5E6D65),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallInfo(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: darkText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8A978F),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 80,
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: primaryGreen,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No special pickups available',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'New special pickups opened by your municipality '
            'will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF718078),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DETAILS
  // ---------------------------------------------------------

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
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
              30,
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
                      color: const Color(0xFFDDE4E0),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pickup.title.isEmpty
                            ? 'Special Pickup'
                            : pickup.title,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _statusBadge(pickup),
                  ],
                ),

                if (pickup.description.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    pickup.description,
                    style: const TextStyle(
                      color: Color(0xFF66766E),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                _detailRow(
                  'Date',
                  _formatDate(pickup.pickupDate),
                ),
                _detailRow(
                  'Time',
                  '${_formatTime(pickup.startTime)}'
                      ' - ${_formatTime(pickup.endTime)}',
                ),
                _detailRow(
                  'Location',
                  _locationText(pickup),
                ),
                _detailRow(
                  'Waste Types',
                  pickup.acceptedWasteTypes.isEmpty
                      ? '-'
                      : pickup.acceptedWasteTypes.join(', '),
                ),
                _detailRow(
                  'Households',
                  '${pickup.joinedHouseholds}'
                      '/${pickup.maxHouseholds}',
                ),
                _detailRow(
                  'Minimum Required',
                  '${pickup.minHouseholds}',
                ),
                _detailRow(
                  'Weight Available',
                  '${_number(pickup.remainingWeightKg)} kg',
                ),
                _detailRow(
                  'Volume Available',
                  '${_number(pickup.remainingVolumeM3)} m³',
                ),

                const SizedBox(height: 18),

                if (pickup.isCancelled)
                  _buildCancelledDetails(pickup)
                else if (pickup.hasJoinRequest)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _joinStatusText(pickup),
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (pickup.canJoin)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openJoinForm(pickup);
                      },
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                      ),
                      label: const Text(
                        'Join Special Pickup',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'This special pickup is not available '
                      'for joining.',
                      style: TextStyle(
                        color: Color(0xFF986300),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelledDetails(SpecialPickup pickup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFCACA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.cancel_rounded,
                color: cancelledRed,
                size: 20,
              ),
              SizedBox(width: 7),
              Text(
                'Pickup Cancelled',
                style: TextStyle(
                  color: cancelledRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Reason',
            style: TextStyle(
              color: Color(0xFF9C6262),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _cancellationReason(pickup),
            style: const TextStyle(
              color: Color(0xFF7D3333),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (pickup.hasJoinRequest) ...[
            const SizedBox(height: 12),
            const Divider(
              color: Color(0xFFFFCACA),
              height: 1,
            ),
            const SizedBox(height: 12),
            const Text(
              'You had joined this pickup. '
              'The collection will not take place.',
              style: TextStyle(
                color: Color(0xFF7D3333),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // JOIN FORM
  // ---------------------------------------------------------

  Future<void> _openJoinForm(
    SpecialPickup pickup,
  ) async {
    final wasteTypeController = TextEditingController();
    final itemCountController =
        TextEditingController(text: '1');
    final sizeController =
        TextEditingController(text: 'Medium');
    final weightController = TextEditingController();
    final volumeController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    if (pickup.acceptedWasteTypes.isNotEmpty) {
      wasteTypeController.text =
          pickup.acceptedWasteTypes.first;
    }

    var submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Join Special Pickup',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _joinField(
                        controller: wasteTypeController,
                        label: 'Waste Type',
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 12),
                      _joinField(
                        controller: itemCountController,
                        label: 'Number of Items',
                        keyboardType: TextInputType.number,
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 12),
                      _joinField(
                        controller: sizeController,
                        label: 'Estimated Size',
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 12),
                      _joinField(
                        controller: weightController,
                        label: 'Estimated Weight (kg)',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 12),
                      _joinField(
                        controller: volumeController,
                        label: 'Estimated Volume (m³)',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 12),
                      _joinField(
                        controller: addressController,
                        label: 'Pickup Address',
                        enabled: !submitting,
                      ),
                      const SizedBox(height: 12),
                      _joinField(
                        controller: notesController,
                        label: 'Notes (Optional)',
                        enabled: !submitting,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final numberOfItems = int.tryParse(
                            itemCountController.text.trim(),
                          );

                          final weight = double.tryParse(
                            weightController.text.trim(),
                          );

                          final volume = double.tryParse(
                            volumeController.text.trim(),
                          );

                          if (wasteTypeController.text
                                  .trim()
                                  .isEmpty ||
                              numberOfItems == null ||
                              numberOfItems <= 0 ||
                              sizeController.text
                                  .trim()
                                  .isEmpty ||
                              weight == null ||
                              weight <= 0 ||
                              volume == null ||
                              volume <= 0 ||
                              addressController.text
                                  .trim()
                                  .isEmpty) {
                            _showMessage(
                              'Please enter all required '
                              'pickup details correctly.',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() {
                            submitting = true;
                          });

                          try {
                            await _service.joinSpecialPickup(
                              pickupId: pickup.id,
                              wasteType:
                                  wasteTypeController.text.trim(),
                              numberOfItems: numberOfItems,
                              estimatedSize:
                                  sizeController.text.trim(),
                              estimatedWeightKg: weight,
                              estimatedVolumeM3: volume,
                              pickupAddress:
                                  addressController.text.trim(),
                              notes:
                                  notesController.text.trim().isEmpty
                                      ? null
                                      : notesController.text.trim(),
                            );

                            if (!mounted ||
                                !dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            _showMessage(
                              'You joined the special pickup '
                              'successfully.',
                            );

                            await _loadPickups();
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              submitting = false;
                            });

                            if (!mounted) return;

                            _showMessage(
                              _cleanError(e),
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Join'),
                ),
              ],
            );
          },
        );
      },
    );

    wasteTypeController.dispose();
    itemCountController.dispose();
    sizeController.dispose();
    weightController.dispose();
    volumeController.dispose();
    addressController.dispose();
    notesController.dispose();
  }

  Widget _joinField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF87938D),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: darkText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? const Color(0xFFD94C4C)
            : primaryGreen,
      ),
    );
  }

  String _cardStatusText(SpecialPickup pickup) {
    if (pickup.isCancelled) {
      return 'This pickup has been cancelled.';
    }

    if (pickup.hasJoinRequest) {
      return _joinStatusText(pickup);
    }

    if (pickup.canJoin) {
      return 'Open for residents to join';
    }

    return 'Not available for joining';
  }

  String _cancellationReason(SpecialPickup pickup) {
    final reason = pickup.cancellationReason?.trim();

    if (reason == null || reason.isEmpty) {
      return 'No cancellation reason was provided.';
    }

    return reason;
  }

  String _joinStatusText(SpecialPickup pickup) {
    if (pickup.isApproved) {
      return 'You have joined this special pickup.';
    }

    if (pickup.isPending) {
      return 'Your join request is pending.';
    }

    if (pickup.isRejected) {
      return 'Your join request was rejected.';
    }

    return 'Join request submitted.';
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

    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]);

    if (hour == null) return time;

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