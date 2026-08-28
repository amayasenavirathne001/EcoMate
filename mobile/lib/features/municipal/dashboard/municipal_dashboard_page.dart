import 'package:flutter/material.dart';
import 'models/municipal_dashboard_models.dart';
import 'services/municipal_dashboard_service.dart';
import '../theme/municipal_colors.dart';
import 'widgets/summary_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/quick_actions.dart';

class MunicipalDashboardPage extends StatefulWidget {
  final Function(int) onTabChange;

  const MunicipalDashboardPage({
    super.key,
    required this.onTabChange,
  });

  @override
  State<MunicipalDashboardPage> createState() => _MunicipalDashboardPageState();
}

class _MunicipalDashboardPageState extends State<MunicipalDashboardPage> {
  final MunicipalDashboardService _dashboardService = MunicipalDashboardService();
  MunicipalDashboardSummary? _summaryData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthStr = months[now.month - 1];
    return "Today, ${now.day} $monthStr ${now.year}";
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            IconButton(
              icon: const Icon(Icons.menu, color: MunicipalColors.primaryText, size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
            ),
            const SizedBox(width: 12),
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
            Stack(
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
                      color: Color(0xFF22C55E), // Green notification badge
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Profile image
            CircleAvatar(
              radius: 20,
              backgroundColor: MunicipalColors.surface,
              child: ClipOval(
                child: Image.network(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop&q=60',
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person_rounded,
                    color: MunicipalColors.secondaryText,
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
                      const Text.rich(
                        TextSpan(
                          text: "Good morning, Alex! ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: "🖐️",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
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
                _buildTruckIllustration(),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          
          // Bottom summary bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildBannerMetric(
                    icon: Icons.delete_outline_rounded,
                    value: "${_summaryData!.totalCollectionsToday}",
                    label: "Collections\nToday",
                  ),
                ),
                _buildMetricDivider(),
                Expanded(
                  child: _buildBannerMetric(
                    icon: Icons.local_shipping_outlined,
                    value: "${_summaryData!.activeCollectors}",
                    label: "Active\nTrucks",
                  ),
                ),
                _buildMetricDivider(),
                Expanded(
                  child: _buildBannerMetric(
                    icon: Icons.forum_outlined,
                    value: "${_summaryData!.pendingComplaints}",
                    label: "Complaints\nOpen",
                  ),
                ),
                _buildMetricDivider(),
                Expanded(
                  child: _buildBannerMetric(
                    icon: Icons.eco_outlined,
                    value: "${_summaryData!.recyclingRate}%",
                    label: "Recycling\nRate",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckIllustration() {
    return SizedBox(
      width: 130,
      height: 70,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          // Truck Bed (Green body)
          Positioned(
            left: 5,
            bottom: 12,
            child: Container(
              width: 75,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF047857), // emerald dark green
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.recycling_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          // Truck Cab (White head)
          Positioned(
            left: 83,
            bottom: 12,
            child: Container(
              width: 30,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(3),
                  topLeft: Radius.circular(2),
                  bottomLeft: Radius.circular(2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Window
                  Positioned(
                    top: 5,
                    right: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Connector
          Positioned(
            left: 80,
            bottom: 16,
            child: Container(
              width: 4,
              height: 8,
              color: const Color(0xFF94A3B8),
            ),
          ),
          // Wheels
          Positioned(
            left: 16,
            bottom: 2,
            child: _buildWheel(),
          ),
          Positioned(
            left: 54,
            bottom: 2,
            child: _buildWheel(),
          ),
          Positioned(
            left: 92,
            bottom: 2,
            child: _buildWheel(),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildBannerMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 10,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
      childAspectRatio: 0.92,
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
