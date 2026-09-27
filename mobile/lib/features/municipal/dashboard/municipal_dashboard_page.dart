import 'dart:convert';
import 'package:flutter/material.dart';
import 'models/municipal_dashboard_models.dart';
import 'services/municipal_dashboard_service.dart';
import '../../../../services/auth_service.dart';
import '../../../screens/login_screen.dart';
import '../theme/municipal_colors.dart';
import 'widgets/summary_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/live_map_preview_card.dart';
import '../operations/screens/smart_alerts_screen.dart';

class MunicipalDashboardPage extends StatefulWidget {
  final Function(int) onTabChange;

  const MunicipalDashboardPage({super.key, required this.onTabChange});

  @override
  State<MunicipalDashboardPage> createState() => _MunicipalDashboardPageState();
}

class _MunicipalDashboardPageState extends State<MunicipalDashboardPage> {
  final MunicipalDashboardService _dashboardService =
      MunicipalDashboardService();
  final AuthService _authService = AuthService();
  MunicipalDashboardSummary? _summaryData;
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = 'Officer';
  String _profilePicUrl =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    AuthService.profileUpdateNotifier.addListener(_onProfileUpdated);
  }

  void _onProfileUpdated() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  @override
  void dispose() {
    AuthService.profileUpdateNotifier.removeListener(_onProfileUpdated);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (mounted && user != null) {
        final name = user['name']?.toString();
        if (name != null && name.isNotEmpty) {
          _userName = name;
        }
        final pic = user['profilePic']?.toString();
        if (pic != null && pic.isNotEmpty) {
          _profilePicUrl = pic;
        }
      }
      final data = await _dashboardService.getDashboardSummary();
      setState(() {
        _summaryData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
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
    final monthStr = months[now.month - 1];
    return "Today, ${now.day} $monthStr ${now.year}";
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  String _getFirstName() {
    try {
      final name = _userName as dynamic;
      if (name == null) return 'Officer';
      final str = name.toString();
      if (str.isEmpty) return 'Officer';
      return str.split(' ').first;
    } catch (e) {
      return 'Officer';
    }
  }

  String _getProfilePic() {
    try {
      final pic = _profilePicUrl as dynamic;
      if (pic == null)
        return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60';
      final str = pic.toString();
      if (str.isEmpty)
        return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60';
      return str;
    } catch (e) {
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: MunicipalColors.secondaryGreen,
                ),
              )
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: MunicipalColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MunicipalColors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MunicipalColors.secondaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: MunicipalColors.secondaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildWelcomeTitle(),
                          const SizedBox(height: 20),
                          _buildHeroBanner(),
                          const SizedBox(height: 24),

                          QuickActionsWidget(
                            onManageSchedules: () => widget.onTabChange(2),
                            onAssignCollectors: () => widget.onTabChange(1),
                            onViewReports: () => widget.onTabChange(3),
                            onSendAlerts: () {},
                          ),
                          const SizedBox(height: 24),
                          _buildKeyStatisticsHeader(),
                          const SizedBox(height: 14),
                          _buildSummaryGrid(),
                          const SizedBox(height: 24),

                          const LiveMapPreviewCard(),
                          const SizedBox(height: 24),

                          ScheduleCard(
                            schedules: _summaryData!.todaySchedules,
                            onViewAll: () => widget.onTabChange(2),
                            onViewFullSchedule: () => widget.onTabChange(2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.spa_rounded,
              color: MunicipalColors.secondaryGreen,
              size: 32,
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoMate',
                  style: TextStyle(
                    color: Color(0xFF0D3C38),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Municipal Council',
                  style: TextStyle(
                    color: MunicipalColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Notification Icon with Badge
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartAlertsScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: MunicipalColors.primaryText,
                    size: 28,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE23636), // Red notification badge
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_summaryData?.activeAlerts ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Profile image with logout menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: MunicipalColors.error,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: MunicipalColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 20,
                backgroundColor: MunicipalColors.surface,
                child: ClipOval(
                  child: _getProfilePic().startsWith('data:image')
                      ? Image.memory(
                          base64Decode(_getProfilePic().split(',').last),
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person_rounded,
                                color: MunicipalColors.secondaryText,
                              ),
                        )
                      : Image.network(
                          _getProfilePic(),
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person_rounded,
                                color: MunicipalColors.secondaryText,
                              ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getFormattedDate(),
          style: const TextStyle(
            color: MunicipalColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF028B9F), // Deep teal
            Color(0xFF028B6B), // Green-teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF028B6B).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top greeting and illustration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "${_getGreeting()}, ${_getFirstName()}!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text("🖐️", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Here's what's happening in your city today.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildHeroIllustration(),
              ],
            ),
          ),
          // End of banner
        ],
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.eco_rounded, color: Colors.white, size: 34),
        ],
      ),
    );
  }

  Widget _buildKeyStatisticsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Key Statistics",
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            children: [
              Text(
                "View All",
                style: TextStyle(
                  color: MunicipalColors.secondaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                color: MunicipalColors.secondaryGreen,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.7,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        SummaryCard(
          title: "Total Collections Today",
          value: "${_summaryData!.totalCollectionsToday}",
          subtitle: "+14% vs yesterday",
          icon: Icons.delete_outline_rounded,
          iconColor: const Color(0xFF22C55E),
          backgroundColor: const Color(0xFFF2FAF6),
          comparisonWidget: const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF22C55E),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                "12% vs yesterday",
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SummaryCard(
          title: "Active Trucks On Duty",
          value: "${_summaryData!.activeCollectors}",
          subtitle: "On duty now",
          icon: Icons.local_shipping_outlined,
          iconColor: const Color(0xFF3B82F6),
          backgroundColor: const Color(0xFFF4F8FD),
          comparisonWidget: const Row(
            children: [
              Text(
                "—",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Text(
                "No change",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SummaryCard(
          title: "Pending Complaints",
          value: "${_summaryData!.pendingComplaints}",
          subtitle: "5 High Priority",
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFF8F2),
          comparisonWidget: const Row(
            children: [
              Icon(
                Icons.trending_down_rounded,
                color: Color(0xFFF97316),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                "8% vs yesterday",
                style: TextStyle(
                  color: Color(0xFFF97316),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SummaryCard(
          title: "Recycling Rate This Month",
          value: "${_summaryData!.recyclingRate}%",
          subtitle: "+6% vs last month",
          icon: Icons.eco_outlined,
          iconColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFFF1F9F6),
          comparisonWidget: const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF10B981),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                "5% vs last month",
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
