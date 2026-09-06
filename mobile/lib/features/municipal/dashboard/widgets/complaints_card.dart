import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/municipal_dashboard_models.dart';

class ComplaintsCard extends StatelessWidget {
  final List<ComplaintSummary> complaints;
  final VoidCallback onViewAll;
  final VoidCallback onViewAllComplaints;

  const ComplaintsCard({
    super.key,
    required this.complaints,
    required this.onViewAll,
    required this.onViewAllComplaints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MunicipalColors.primaryBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MunicipalColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Reports / Complaints",
                style: TextStyle(
                  color: MunicipalColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View all",
                  style: TextStyle(
                    color: MunicipalColors.secondaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Complaints List
          if (complaints.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "No recent reports or complaints.",
                style: TextStyle(color: MunicipalColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: complaints.length,
              separatorBuilder: (context, index) => const Divider(
                color: MunicipalColors.border,
                height: 24,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final item = complaints[index];
                
                // Color configuration based on priority
                Color badgeBg;
                Color badgeText;
                IconData icon;
                Color iconColor;
                Color iconBg;

                switch (item.priority.toLowerCase()) {
                  case 'high':
                    badgeBg = MunicipalColors.error.withValues(alpha: 0.12);
                    badgeText = MunicipalColors.error;
                    icon = Icons.warning_amber_rounded;
                    iconColor = MunicipalColors.error;
                    iconBg = MunicipalColors.error.withValues(alpha: 0.08);
                    break;
                  case 'medium':
                    badgeBg = MunicipalColors.warning.withValues(alpha: 0.12);
                    badgeText = const Color(0xFFD97706); // Amber/orange
                    icon = Icons.report_problem_outlined;
                    iconColor = const Color(0xFFD97706);
                    iconBg = MunicipalColors.warning.withValues(alpha: 0.08);
                    break;
                  case 'low':
                  default:
                    badgeBg = MunicipalColors.success.withValues(alpha: 0.12);
                    badgeText = MunicipalColors.success;
                    icon = Icons.delete_outline_rounded;
                    iconColor = MunicipalColors.success;
                    iconBg = MunicipalColors.success.withValues(alpha: 0.08);
                    break;
                }

                return Row(
                  children: [
                    // Icon inside rounded container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: MunicipalColors.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.location,
                            style: const TextStyle(
                              color: MunicipalColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.timeAgo,
                            style: const TextStyle(
                              color: MunicipalColors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.priority,
                        style: TextStyle(
                          color: badgeText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          const Divider(color: MunicipalColors.border, height: 24, thickness: 1),

          // Bottom Navigation Text Button
          InkWell(
            onTap: onViewAllComplaints,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "View all complaints",
                    style: TextStyle(
                      color: MunicipalColors.secondaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: MunicipalColors.secondaryGreen,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
