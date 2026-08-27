import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../recycling/waste_segregation_guide_screen.dart';
import '../collection_schedule_screen.dart';
import '../report_issue_screen.dart';
import '../my_reports_screen.dart';

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() =>
      _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  final AuthService _authService = AuthService();

  int _selectedIndex = 0;
  String _userName = 'Resident';

  static const Color darkText = Color(0xFF071A26);
  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color mediumGreen = Color(0xFF2E7D32);
  static const Color softGreen = Color(0xFFEDF8EC);
  static const Color background = Color(0xFFFAFCFA);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await _authService.getCurrentUser();

      if (!mounted) return;

      if (user != null) {
        final name = user['name']?.toString();

        if (name != null && name.isNotEmpty) {
          setState(() {
            _userName = name;
          });
        }
      }
    } catch (_) {
      // Keep default name if user information cannot be loaded.
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const CollectionScheduleScreen(),
        ),
      );

      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ReportIssueScreen(),
        ),
      );

      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyReportsScreen(),
        ),
      );

      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      drawer: _buildDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            14,
            8,
            14,
            105,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 12),

                  _buildGreetingCard(),

                  const SizedBox(height: 18),

                  _buildPickupCard(),

                  const SizedBox(height: 18),

                  _buildWasteCategoryCard(),

                  const SizedBox(height: 18),

                  _buildQuickActions(),

                  const SizedBox(height: 18),

                  _buildStatsSection(),

                  const SizedBox(height: 18),

                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 78,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu_rounded,
                  size: 33,
                  color: darkText,
                ),
              ),

              const Spacer(),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: 'Eco',
                      style: TextStyle(
                        color: darkText,
                      ),
                    ),
                    TextSpan(
                      text: 'Mate',
                      style: TextStyle(
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 33,
                      color: darkText,
                    ),
                  ),

                  Positioned(
                    top: 7,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // GREETING CARD
  // ==========================================================

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF9FFF7),
            Color(0xFFF1F9ED),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFDCEBD7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFDDEED8),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/resident_profile.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    size: 45,
                    color: mediumGreen,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_userName 👋',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Good to see you again!',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 7),

          const Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                'Eco Points',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),

              SizedBox(height: 4),

              Row(
                children: [
                  Icon(
                    Icons.eco_rounded,
                    color: primaryGreen,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '1,250',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BULK PICKUP
  // ==========================================================

  Widget _buildPickupCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.055,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F9F0),
              borderRadius:
                  BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: primaryGreen,
              size: 37,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'SPECIAL BULK PICKUP',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Friday, 23 May 2025',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 16,
                  runSpacing: 9,
                  children: [
                    _pickupInfo(
                      Icons.schedule_rounded,
                      '6:00 AM - 9:00 AM',
                    ),

                    _pickupInfo(
                      Icons.eco_outlined,
                      'Organic Waste',
                    ),

                    _pickupInfo(
                      Icons.location_on_outlined,
                      '123, Green Lane, Colombo 07',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.black54,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _pickupInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ORGANIC WASTE CARD
  // ==========================================================

  Widget _buildWasteCategoryCard() {
    return Container(
      width: double.infinity,
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF006247),
            Color(0xFF007458),
            Color(0xFF00543F),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                4,
                20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TODAY\'S WASTE CATEGORY',
                    style: TextStyle(
                      color: Color(0xFFCBE6B6),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Organic Waste',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Colors.white,
                        child: Icon(
                          Icons.eco_rounded,
                          color:
                              primaryGreen,
                          size: 23,
                        ),
                      ),

                      SizedBox(width: 9),

                      Text(
                        'Keep it green!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Only organic waste today.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: 155,
            child: Image.asset(
              'assets/images/organic_waste_bin.png',
              fit: BoxFit.contain,
              alignment:
                  Alignment.bottomRight,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 100,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // QUICK ACTIONS
  // ==========================================================

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.68,
      children: [
        _quickAction(
          icon: Icons.calendar_month_rounded,
          title: 'View\nSchedule',
          color: const Color(0xFF00624F),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const CollectionScheduleScreen(),
              ),
            );
          },
        ),

        _quickAction(
          icon: Icons.local_shipping_rounded,
          title: 'Request\nPickup',
          color: const Color(0xFF19A86A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const WastePickupRequestScreen(),
              ),
            );
          },
        ),

        _quickAction(
          icon:
              Icons.warning_amber_rounded,
          title: 'Report\nIssue',
          color: const Color(0xFFFF7600),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReportIssueScreen(),
              ),
            );
          },
        ),

        _quickAction(
          icon: Icons.menu_book_rounded,
          title: 'Recycling\nGuide',
          color: const Color(0xFF72C957),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const WasteSegregationGuideScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
              vertical: 8,
          horizontal: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.045,
              ),
              blurRadius: 11,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkText,
                fontSize: 12,
                height: 1.25,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STATS
  // ==========================================================

  Widget _buildStatsSection() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.69,
      children: [
        _statCard(
          icon: Icons.recycling_rounded,
          value: '45',
          title: 'Items Recycled',
          subtitle: 'This Month',
          footer: '↑ 12% vs last month',
        ),

        _statCard(
          icon:
              Icons.local_shipping_rounded,
          value: '3',
          title: 'Pickup Requests',
          subtitle: 'This Month',
          footer: '✓ 2 Completed',
        ),

        _statCard(
          icon: Icons.eco_rounded,
          value: '1,250',
          title: 'Community Score',
          subtitle: 'Great job!',
          footer: 'Top 20% in your area',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
    required String footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 11,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: softGreen,
                child: Icon(
                  icon,
                  color: primaryGreen,
                  size: 22,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            footer,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RECENT ACTIVITY
  // ==========================================================

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: darkText,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          _activityItem(
            icon:
                Icons.local_shipping_rounded,
            title: 'Pickup Completed',
            category: 'Organic Waste',
            date:
                'May 16, 2025 • 7:15 AM',
            completed: true,
          ),

          const Divider(),

          _activityItem(
            icon: Icons.description_rounded,
            title: 'Request Submitted',
            category: 'Recyclables',
            date:
                'May 14, 2025 • 4:30 PM',
            completed: false,
          ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String category,
    required String date,
    required bool completed,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: softGreen,
            child: Icon(
              icon,
              color: primaryGreen,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  category,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.chevron_right_rounded,
            color: completed
                ? primaryGreen
                : Colors.black45,
            size: 27,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DRAWER
  // ==========================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            const Text(
              'EcoMate',
              style: TextStyle(
                color: darkText,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(
                Icons.home_rounded,
                color: primaryGreen,
              ),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month_outlined,
              ),
              title:
                  const Text('Schedule'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.local_shipping_outlined,
              ),
              title: const Text(
                'Pickup Requests',
              ),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
              ),
              title:
                  const Text('Report Issue'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.recycling_rounded,
              ),
              title: const Text(
                'Recycling Guide',
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const WasteSegregationGuideScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onTap: _logout,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 77,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _bottomItem(
                0,
                Icons.home_rounded,
                'Home',
              ),

              _bottomItem(
                1,
                Icons.calendar_month_outlined,
                'Schedule',
              ),

              GestureDetector(
                onTap: () {
                  _onBottomNavTap(2);
                },
                child: Transform.translate(
                  offset: const Offset(0, -15),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10A85B,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                alpha: 0.17,
                              ),
                              blurRadius: 13,
                              offset:
                                  const Offset(
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        'Report',
                        style: TextStyle(
                          color:
                              Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _bottomItem(
                3,
                Icons.description_outlined,
                'Activity',
              ),

              _bottomItem(
                4,
                Icons.person_outline_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(
    int index,
    IconData icon,
    String label,
  ) {
    final selected =
        _selectedIndex == index;

    return InkWell(
      onTap: () {
        _onBottomNavTap(index);
      },
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? primaryGreen
                  : Colors.black45,
              size: 26,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? primaryGreen
                    : Colors.black45,
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}