import 'package:flutter/material.dart';
import 'collection_calendar_screen.dart';

class CollectionScheduleScreen extends StatefulWidget {
  const CollectionScheduleScreen({super.key});

  @override
  State<CollectionScheduleScreen> createState() =>
      _CollectionScheduleScreenState();
}

class _CollectionScheduleScreenState
    extends State<CollectionScheduleScreen> {
  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color darkGreen = Color(0xFF006247);
  static const Color darkText = Color(0xFF071A26);
  static const Color background = Color(0xFFF8FAF7);
  static const Color softGreen = Color(0xFFEDF8EC);

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> schedules = [
    {
      'day': '25',
      'month': 'AUG',
      'title': 'Organic Waste',
      'time': '6:00 AM - 9:00 AM',
      'location': 'Green Lane, Colombo 07',
      'status': 'Upcoming',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF2E7D32),
    },
    {
      'day': '27',
      'month': 'AUG',
      'title': 'Recyclable Waste',
      'time': '7:00 AM - 10:00 AM',
      'location': 'Green Lane, Colombo 07',
      'status': 'Upcoming',
      'icon': Icons.recycling_rounded,
      'color': const Color(0xFF168C83),
    },
    {
      'day': '30',
      'month': 'AUG',
      'title': 'General Waste',
      'time': '6:30 AM - 9:30 AM',
      'location': 'Green Lane, Colombo 07',
      'status': 'Upcoming',
      'icon': Icons.delete_outline_rounded,
      'color': const Color(0xFF607D8B),
    },
    {
      'day': '02',
      'month': 'SEP',
      'title': 'Special Bulk Pickup',
      'time': '8:00 AM - 12:00 PM',
      'location': 'Community Collection Point',
      'status': 'Special',
      'icon': Icons.local_shipping_rounded,
      'color': const Color(0xFFF28C28),
    },
  ];

  List<Map<String, dynamic>> get filteredSchedules {
    if (selectedFilter == 'All') {
      return schedules;
    }

    return schedules
        .where(
          (schedule) =>
              schedule['title']
                  .toString()
                  .toLowerCase()
                  .contains(selectedFilter.toLowerCase()),
        )
        .toList();
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
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildNextCollectionCard(),

                    const SizedBox(height: 24),

                    const Text(
                      'Collection Schedule',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'View upcoming waste collections in your area.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildFilterButtons(),

                    const SizedBox(height: 20),

                    ...filteredSchedules.map(
                      (schedule) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: _buildScheduleCard(
                          schedule,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        18,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: darkText,
              size: 28,
            ),
          ),

          const SizedBox(width: 4),

          const Expanded(
            child: Text(
              'Collection Schedule',
              style: TextStyle(
                color: darkText,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CollectionCalendarScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: softGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NEXT COLLECTION
  // ============================================================

  Widget _buildNextCollectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF006247),
            Color(0xFF0A7C58),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(
              alpha: 0.20,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT COLLECTION',
                  style: TextStyle(
                    color: Color(0xFFCDEDD8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Organic Waste',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white70,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Monday, 25 August',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Colors.white70,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '6:00 AM - 9:00 AM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilterButtons() {
    final filters = [
      'All',
      'Organic',
      'Recyclable',
      'General',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map(
          (filter) {
            final selected =
                selectedFilter == filter;

            return Padding(
              padding:
                  const EdgeInsets.only(right: 9),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryGreen
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                          ? primaryGreen
                          : const Color(0xFFDDE7DC),
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.black54,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ============================================================
  // SCHEDULE CARD
  // ============================================================

  Widget _buildScheduleCard(
    Map<String, dynamic> schedule,
  ) {
    final Color scheduleColor =
        schedule['color'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.045,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 70,
            decoration: BoxDecoration(
              color: scheduleColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  schedule['day'],
                  style: TextStyle(
                    color: scheduleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  schedule['month'],
                  style: TextStyle(
                    color: scheduleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            scheduleColor.withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        schedule['icon']
                            as IconData,
                        color: scheduleColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        schedule['title'],
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 17,
                      color: Colors.black45,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      schedule['time'],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: Colors.black45,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        schedule['location'],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: schedule['status'] ==
                          'Special'
                      ? const Color(0xFFFFF1E5)
                      : softGreen,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  schedule['status'],
                  style: TextStyle(
                    color: schedule['status'] ==
                            'Special'
                        ? const Color(0xFFE57A16)
                        : primaryGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black38,
              ),
            ],
          ),
        ],
      ),
    );
  }
}