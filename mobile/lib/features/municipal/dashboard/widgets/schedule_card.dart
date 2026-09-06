import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/municipal_dashboard_models.dart';

class ScheduleCard extends StatelessWidget {
  final List<CollectionScheduleItem> schedules;
  final VoidCallback onViewAll;
  final VoidCallback onViewFullSchedule;

  const ScheduleCard({
    super.key,
    required this.schedules,
    required this.onViewAll,
    required this.onViewFullSchedule,
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: MunicipalColors.secondaryGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Today's Schedule",
                    style: TextStyle(
                      color: MunicipalColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewFullSchedule,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View Full Schedule",
                  style: TextStyle(
                    color: MunicipalColors.secondaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule List
          if (schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "No collections scheduled for today.",
                style: TextStyle(color: MunicipalColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = schedules[index];
                final status = item.status.toLowerCase();
                
                // Color configuration based on status
                Color dotColor;
                Color badgeBg;
                Color badgeText;
                String displayStatus;

                if (status == 'in progress') {
                  dotColor = const Color(0xFF22C55E); // Green
                  badgeBg = const Color(0xFFDCFCE7);
                  badgeText = const Color(0xFF15803D);
                  displayStatus = "In Progress";
                } else if (status == 'upcoming') {
                  dotColor = const Color(0xFF3B82F6); // Blue
                  badgeBg = const Color(0xFFDBEAFE);
                  badgeText = const Color(0xFF1D4ED8);
                  displayStatus = "Upcoming";
                } else {
                  dotColor = const Color(0xFF0D9488); // Teal for Scheduled
                  badgeBg = const Color(0xFFF3F4F6);
                  badgeText = const Color(0xFF4B5563);
                  displayStatus = "Scheduled";
                }

                // Format time interval nicely
                String timeInterval = item.time;
                if (item.time == "06:00 AM") {
                  timeInterval = "6:00 AM — 10:00 AM";
                } else if (item.time == "10:00 AM") {
                  timeInterval = "10:30 AM — 2:30 PM";
                } else if (item.time == "02:00 PM") {
                  timeInterval = "3:00 PM — 7:00 PM";
                } else {
                  timeInterval = "${item.time} — ${item.type}";
                }

                return Row(
                  children: [
                    // Dot Indicator
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Time info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.zone,
                            style: const TextStyle(
                              color: MunicipalColors.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeInterval,
                            style: const TextStyle(
                              color: MunicipalColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          color: badgeText,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Chevron Arrow
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: MunicipalColors.secondaryText,
                      size: 20,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
