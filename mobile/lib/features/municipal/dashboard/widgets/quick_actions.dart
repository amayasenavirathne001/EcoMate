import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../../../screens/recycling/waste_segregation_guide_screen.dart';
import '../screens/collection_performance_page.dart';
import '../../reports/complaints_requests_page.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onManageSchedules;
  final VoidCallback onAssignCollectors;
  final VoidCallback onViewReports;
  final VoidCallback onSendAlerts;

  const QuickActionsWidget({
    super.key,
    required this.onManageSchedules,
    required this.onAssignCollectors,
    required this.onViewReports,
    required this.onSendAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 85,
                child: _buildActionButton(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF22C55E), // Green
                  label: "Schedule",
                  onTap: onManageSchedules,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 85,
                child: _buildActionButton(
                  icon: Icons.forum_rounded,
                  iconColor: const Color(0xFF06B6D4), // Teal
                  label: "Complaints",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComplaintsRequestsPage(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 85,
                child: _buildActionButton(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF16A34A), // Forest Green
                  label: "Guide",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WasteSegregationGuideScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 85,
                child: _buildActionButton(
                  icon: Icons.speed_rounded,
                  iconColor: const Color(0xFF8B5CF6), // Purple
                  label: "Performance",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CollectionPerformancePage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MunicipalColors.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}