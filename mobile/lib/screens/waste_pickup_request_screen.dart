import 'package:flutter/material.dart';

class WastePickupRequestScreen extends StatefulWidget {
  const WastePickupRequestScreen({super.key});

  @override
  State<WastePickupRequestScreen> createState() =>
      _WastePickupRequestScreenState();
}

class _WastePickupRequestScreenState
    extends State<WastePickupRequestScreen> {
  static const Color darkText = Color(0xFF15292E);
  static const Color primary = Color(0xFF074047);
  static const Color accent = Color(0xFF1DA27E);
  static const Color background = Color(0xFFF7FAFA);
  static const Color border = Color(0xFFD5E0E0);
  static const Color softGreen = Color(0xFFEEF7F0);

  int currentStep = 0;

  String selectedWasteType = 'Metal';
  double quantity = 3;

  final notesController = TextEditingController();
  final instructionsController = TextEditingController();

  String selectedAddress =
      '123 Eco Ave, Green District\nSeattle, WA 98101';

  int selectedDateIndex = 0;
  String selectedTimeSlot = 'Morning';

  final List<Map<String, dynamic>> wasteTypes = [
    {
      'name': 'Plastic',
      'icon': Icons.recycling_rounded,
    },
    {
      'name': 'Paper',
      'icon': Icons.description_outlined,
    },
    {
      'name': 'Glass',
      'icon': Icons.wine_bar_outlined,
    },
    {
      'name': 'Metal',
      'icon': Icons.hardware_outlined,
    },
    {
      'name': 'Organic',
      'icon': Icons.eco_outlined,
    },
    {
      'name': 'E-Waste',
      'icon': Icons.laptop_outlined,
    },
  ];

  final List<Map<String, String>> availableDates = [
    {
      'label': 'TODAY',
      'day': '14',
    },
    {
      'label': 'TOMORROW',
      'day': '15',
    },
    {
      'label': 'WED',
      'day': '16',
    },
    {
      'label': 'THU',
      'day': '17',
    },
  ];

  @override
  void dispose() {
    notesController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
    } else {
      _submitRequest();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _submitRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Waste pickup request submitted successfully!',
        ),
        backgroundColor: Color(0xFF1DA27E),
      ),
    );

    // Later connect this section to Spring Boot.
    //
    // Example data:
    //
    // {
    //   wasteType: selectedWasteType,
    //   quantity: quantity,
    //   notes: notesController.text,
    //   pickupAddress: selectedAddress,
    //   accessInstructions: instructionsController.text,
    //   date: availableDates[selectedDateIndex],
    //   timeSlot: selectedTimeSlot,
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  20,
                ),
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 250),
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        8,
        4,
        16,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousStep,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: primary,
                ),
              ),

              const Expanded(
                child: Text(
                  'Waste Pickup Request',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 48),
            ],
          ),

          LinearProgressIndicator(
            value: (currentStep + 1) / 4,
            minHeight: 3,
            backgroundColor: const Color(
              0xFFE4EEE7,
            ),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildWasteTypeStep();

      case 1:
        return _buildQuantityStep();

      case 2:
        return _buildLocationStep();

      case 3:
        return _buildScheduleStep();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _buildWasteTypeStep() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'Step 1 of 4',
          'Waste Type Selection',
        ),

        const SizedBox(height: 18),

        const Text(
          'Select the primary type of waste for this pickup request.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: wasteTypes.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.65,
          ),
          itemBuilder: (context, index) {
            final item = wasteTypes[index];

            return _wasteTypeCard(
              item['name'] as String,
              item['icon'] as IconData,
            );
          },
        ),

        const SizedBox(height: 24),

        _continueButton(),
      ],
    );
  }

  Widget _wasteTypeCard(
    String name,
    IconData icon,
  ) {
    final selected =
        selectedWasteType == name;

    return InkWell(
      onTap: () {
        setState(() {
          selectedWasteType = name;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? softGreen
              : Colors.white,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primary
                : border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: primary,
                    size: 27,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    name,
                    style: const TextStyle(
                      color: darkText,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  Icons.check_circle,
                  color: primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _buildQuantityStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'Step 2 of 4',
          'Details & Quantity',
        ),

        const SizedBox(height: 18),

        const Text(
          'Provide details about the quantity to ensure proper vehicle assignment.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 20),

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Quantity (Bags)',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Slider(
                value: quantity,
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: primary,
                inactiveColor: border,
                onChanged: (value) {
                  setState(() {
                    quantity = value;
                  });
                },
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),

                  Text(
                    '${quantity.round()} Bags',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    '20+',
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Additional Notes (Optional)',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'E.g., Large cardboard boxes need breaking down...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(
                      color: border,
                    ),
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(
                      color: border,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _continueButton(),
      ],
    );
  }

  // ============================================================
  // STEP 3
  // ============================================================

  Widget _buildLocationStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'Step 3 of 4',
          'Pickup Location',
        ),

        const SizedBox(height: 18),

        const Text(
          'Confirm the pickup location.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 18),

        _sectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                height: 170,
                width: double.infinity,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFE9F0EA),
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.map_outlined,
                        color: primary.withValues(
                          alpha: 0.35,
                        ),
                        size: 100,
                      ),
                    ),

                    const Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        color: primary,
                        size: 44,
                      ),
                    ),

                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration:
                            const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: primary,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        selectedAddress,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: primary,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Access Instructions',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    instructionsController,
                decoration: InputDecoration(
                  hintText:
                      'Gate code, alleyway, etc.',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(
                      color: border,
                    ),
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(
                      color: border,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _continueButton(),
      ],
    );
  }

  // ============================================================
  // STEP 4
  // ============================================================

  Widget _buildScheduleStep() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle(
          'Step 4 of 4',
          'Date & Time',
        ),

        const SizedBox(height: 18),

        const Text(
          'Select a preferred date and time slot for collection.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 20),

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Dates',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: List.generate(
                  availableDates.length,
                  (index) {
                    final selected =
                        selectedDateIndex ==
                            index;

                    return Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(
                          right: index ==
                                  availableDates
                                          .length -
                                      1
                              ? 0
                              : 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedDateIndex =
                                  index;
                            });
                          },
                          borderRadius:
                              BorderRadius
                                  .circular(10),
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 10,
                            ),
                            decoration:
                                BoxDecoration(
                              color: selected
                                  ? softGreen
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                              border: Border.all(
                                color: selected
                                    ? primary
                                    : border,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  availableDates[
                                          index]
                                      ['label']!,
                                  style:
                                      TextStyle(
                                    color: selected
                                        ? primary
                                        : Colors
                                            .black54,
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  availableDates[
                                          index]
                                      ['day']!,
                                  style:
                                      const TextStyle(
                                    color:
                                        darkText,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Time Slot',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              _timeSlotCard(
                title: 'Morning',
                time:
                    '08:00 AM - 12:00 PM',
                icon: Icons.wb_sunny_outlined,
              ),

              const SizedBox(height: 10),

              _timeSlotCard(
                title: 'Afternoon',
                time:
                    '12:00 PM - 04:00 PM',
                icon:
                    Icons.light_mode_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit Request',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeSlotCard({
    required String title,
    required String time,
    required IconData icon,
  }) {
    final selected =
        selectedTimeSlot == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTimeSlot = title;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? softGreen
              : Colors.white,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? primary
                : border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primary,
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTitle(
    String step,
    String title,
  ) {
    return Row(
      children: [
        Text(
          step,
          style: const TextStyle(
            color: darkText,
            fontSize: 12,
          ),
        ),

        const Spacer(),

        Text(
          title,
          style: const TextStyle(
            color: primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: border,
        ),
      ),
      child: child,
    );
  }

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(7),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: border,
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.home_outlined,
            label: 'Home',
          ),
          _BottomItem(
            icon: Icons
                .local_shipping_outlined,
            label: 'Requests',
            selected: true,
          ),
          _BottomItem(
            icon:
                Icons.calendar_month_outlined,
            label: 'Schedules',
          ),
          _BottomItem(
            icon: Icons.person_outline,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFBDF3C7)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected
                ? const Color(0xFF074047)
                : Colors.black54,
            size: 20,
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF074047)
                  : Colors.black54,
              fontSize: 9,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}