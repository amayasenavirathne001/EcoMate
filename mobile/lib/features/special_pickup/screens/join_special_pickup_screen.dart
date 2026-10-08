import 'package:flutter/material.dart';

import '../models/special_pickup.dart';
import '../services/special_pickup_service.dart';

class JoinSpecialPickupScreen extends StatefulWidget {
  final SpecialPickup pickup;

  const JoinSpecialPickupScreen({
    super.key,
    required this.pickup,
  });

  @override
  State<JoinSpecialPickupScreen> createState() =>
      _JoinSpecialPickupScreenState();
}

class _JoinSpecialPickupScreenState
    extends State<JoinSpecialPickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SpecialPickupService();

  final _itemsController = TextEditingController(text: '1');
  final _weightController = TextEditingController();
  final _volumeController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedWasteType;
  String _selectedSize = 'Medium';
  bool _submitting = false;

  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color deepGreen = Color(0xFF006B4F);
  static const Color background = Color(0xFFF7FAF7);
  static const Color darkText = Color(0xFF071A26);

  @override
  void initState() {
    super.initState();

    if (widget.pickup.acceptedWasteTypes.isNotEmpty) {
      _selectedWasteType =
          widget.pickup.acceptedWasteTypes.first;
    }

    _addressController.text = widget.pickup.location;
  }

  @override
  void dispose() {
    _itemsController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _joinPickup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWasteType == null) {
      _showMessage('Please select a waste type.');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await _service.joinSpecialPickup(
        pickupId: widget.pickup.id,
        wasteType: _selectedWasteType!,
        numberOfItems: int.parse(_itemsController.text.trim()),
        estimatedSize: _selectedSize,
        estimatedWeightKg:
            double.parse(_weightController.text.trim()),
        estimatedVolumeM3:
            double.parse(_volumeController.text.trim()),
        pickupAddress: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Successfully joined the special pickup.',
          ),
          backgroundColor: primaryGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        title: const Text(
          'Join Special Pickup',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _buildPickupHeader(),
              const SizedBox(height: 22),

              const Text(
                'Your Waste Details',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Tell us what you would like to add to this pickup.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              _label('Waste Type'),
              const SizedBox(height: 7),

              DropdownButtonFormField<String>(
                initialValue: _selectedWasteType,
                decoration: _inputDecoration(
                  Icons.recycling_rounded,
                ),
                items: widget.pickup.acceptedWasteTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWasteType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a waste type';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Number of Items'),
              const SizedBox(height: 7),

              TextFormField(
                controller: _itemsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  Icons.inventory_2_outlined,
                  hint: 'Example: 2',
                ),
                validator: (value) {
                  final number =
                      int.tryParse(value?.trim() ?? '');

                  if (number == null || number <= 0) {
                    return 'Enter a valid number of items';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Estimated Size'),
              const SizedBox(height: 7),

              DropdownButtonFormField<String>(
                initialValue: _selectedSize,
                decoration: _inputDecoration(
                  Icons.straighten_rounded,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Small',
                    child: Text('Small'),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'Large',
                    child: Text('Large'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSize = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              _label('Estimated Weight (kg)'),
              const SizedBox(height: 7),

              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  Icons.scale_outlined,
                  hint: 'Example: 45',
                ),
                validator: (value) {
                  final number =
                      double.tryParse(value?.trim() ?? '');

                  if (number == null || number <= 0) {
                    return 'Enter a valid estimated weight';
                  }

                  if (number >
                      widget.pickup.remainingWeightKg) {
                    return 'Only ${widget.pickup.remainingWeightKg.toStringAsFixed(1)} kg remaining';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Estimated Volume (m³)'),
              const SizedBox(height: 7),

              TextFormField(
                controller: _volumeController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(
                  Icons.view_in_ar_outlined,
                  hint: 'Example: 1.5',
                ),
                validator: (value) {
                  final number =
                      double.tryParse(value?.trim() ?? '');

                  if (number == null || number <= 0) {
                    return 'Enter a valid estimated volume';
                  }

                  if (number >
                      widget.pickup.remainingVolumeM3) {
                    return 'Only ${widget.pickup.remainingVolumeM3.toStringAsFixed(1)} m³ remaining';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Pickup Address'),
              const SizedBox(height: 7),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: _inputDecoration(
                  Icons.location_on_outlined,
                  hint: 'Enter your pickup address',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Pickup address is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Notes (Optional)'),
              const SizedBox(height: 7),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration(
                  Icons.notes_rounded,
                  hint:
                      'Example: Old sofa and wooden chair',
                ),
              ),

              const SizedBox(height: 20),

              _buildCapacityInfo(),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      _submitting ? null : _joinPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person_add_alt_1_rounded,
                        ),
                  label: Text(
                    _submitting
                        ? 'Joining...'
                        : 'Join Special Pickup',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickupHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pickup.title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pickup.location,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF8EF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFD5EBD8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: deepGreen,
                size: 20,
              ),
              SizedBox(width: 7),
              Text(
                'Available Capacity',
                style: TextStyle(
                  color: deepGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _capacityRow(
            'Household spaces',
            '${widget.pickup.remainingHouseholds}',
          ),
          _capacityRow(
            'Remaining weight',
            '${widget.pickup.remainingWeightKg.toStringAsFixed(1)} kg',
          ),
          _capacityRow(
            'Remaining volume',
            '${widget.pickup.remainingVolumeM3.toStringAsFixed(1)} m³',
          ),
        ],
      ),
    );
  }

  Widget _capacityRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: darkText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration(
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: deepGreen,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDDE5DF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDDE5DF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }
}