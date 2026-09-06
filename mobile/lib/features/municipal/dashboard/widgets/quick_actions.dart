import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../../../screens/recycling/waste_segregation_guide_screen.dart';

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
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF22C55E), // Green
                label: "Schedule",
                onTap: onManageSchedules,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.forum_rounded,
                iconColor: const Color(0xFF06B6D4), // Teal
                label: "Complaints",
                onTap: onViewReports,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.local_shipping_rounded,
                iconColor: const Color(0xFF3B82F6), // Blue
                label: "Vehicles",
                onTap: onAssignCollectors,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFF10B981), // Emerald Green
                label: "Reports",
                onTap: onViewReports,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
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
          ],
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