import 'package:flutter/material.dart';

class CollectionCalendarScreen extends StatefulWidget {
  const CollectionCalendarScreen({super.key});

  @override
  State<CollectionCalendarScreen> createState() =>
      _CollectionCalendarScreenState();
}

class _CollectionCalendarScreenState
    extends State<CollectionCalendarScreen> {
  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color darkText = Color(0xFF071A26);
  static const Color background = Color(0xFFF8FAF7);

  DateTime currentMonth = DateTime(2025, 5);
  DateTime selectedDate = DateTime(2025, 5, 23);

  final Map<int, Color> collectionDays = {
    2: Color(0xFFFF7A00),  // Special
    16: Color(0xFF2E7D32), // Organic
    23: Color(0xFF2E7D32), // Organic
    25: Color(0xFF0E8A38), // Organic
    27: Color(0xFF159FA5), // Recyclable
    30: Color(0xFF455A64), // General
  };

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
      );
    });
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final lastDay = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    final daysInMonth = lastDay.day;

    final firstWeekday = firstDay.weekday;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkText,
          ),
        ),
        title: const Text(
          'Collection Calendar',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.05,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_monthName(currentMonth.month)} ${currentMonth.year}',
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: primaryGreen,
                          ),
                        ),

                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _DayHeader('Mon'),
                        _DayHeader('Tue'),
                        _DayHeader('Wed'),
                        _DayHeader('Thu'),
                        _DayHeader('Fri'),
                        _DayHeader('Sat'),
                        _DayHeader('Sun'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount:
                          (firstWeekday - 1) + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday - 1) {
                          return const SizedBox();
                        }

                        final day =
                            index - (firstWeekday - 1) + 1;

                        final isSelected =
                            selectedDate.year ==
                                    currentMonth.year &&
                                selectedDate.month ==
                                    currentMonth.month &&
                                selectedDate.day == day;

                        final markerColor =
                            collectionDays[day];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = DateTime(
                                currentMonth.year,
                                currentMonth.month,
                                day,
                              );
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE5F5E5)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: TextStyle(
                                    color: isSelected
                                        ? primaryGreen
                                        : darkText,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),

                                if (markerColor != null)
                                  Positioned(
                                    bottom: 5,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: markerColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildLegend(),

              const SizedBox(height: 20),

              _buildSelectedDateInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Wrap(
        spacing: 18,
        runSpacing: 10,
        children: [
          _LegendItem(
            color: Color(0xFF2E7D32),
            text: 'Organic',
          ),
          _LegendItem(
            color: Color(0xFF159FA5),
            text: 'Recyclable',
          ),
          _LegendItem(
            color: Color(0xFF455A64),
            text: 'General',
          ),
          _LegendItem(
            color: Color(0xFFFF7A00),
            text: 'Special',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFEAF5EA),
            child: Icon(
              Icons.calendar_month_rounded,
              color: primaryGreen,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected: ${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}',
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Tap highlighted dates to view collection information.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;

  const _DayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}