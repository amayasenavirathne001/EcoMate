import 'package:flutter/material.dart';
import '../models/pickup_request.dart';

class PickupStatusTimeline extends StatelessWidget {
  final PickupStatus currentStatus;

  const PickupStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStatus == PickupStatus.failed || currentStatus == PickupStatus.rejected) {
      return _buildErrorTimeline();
    }
    return _buildNormalTimeline();
  }

  Widget _buildNormalTimeline() {
    final List<Map<String, dynamic>> stages = [
      {'status': PickupStatus.submitted, 'label': 'Submitted'},
      {'status': PickupStatus.approved, 'label': 'Approved'},
      {'status': PickupStatus.scheduled, 'label': 'Scheduled'},
      {'status': PickupStatus.collectorAssigned, 'label': 'Collector Assigned'},
      {'status': PickupStatus.inProgress, 'label': 'In Progress'},
      {'status': PickupStatus.completed, 'label': 'Completed'},
    ];

    int currentIndex = stages.indexWhere((s) => s['status'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Fallback

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stages.length, (index) {
        final isCompleted = index < currentIndex || currentStatus == PickupStatus.completed;
        final isCurrent = index == currentIndex && currentStatus != PickupStatus.completed;
        final isLast = index == stages.length - 1;

        return _buildTimelineItem(
          label: stages[index]['label'] as String,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
          isError: false,
        );
      }),
    );
  }

  Widget _buildErrorTimeline() {
    final bool isRejected = currentStatus == PickupStatus.rejected;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineItem(
          label: 'Submitted',
          isCompleted: true,
          isCurrent: false,
          isLast: false,
          isError: false,
        ),
        _buildTimelineItem(
          label: isRejected ? 'Rejected' : 'Failed',
          isCompleted: false,
          isCurrent: true,
          isLast: true,
          isError: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String label,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required bool isError,
  }) {
    final Color primaryGreen = const Color(0xFF0E8A38);
    final Color errorColor = const Color(0xFFD32F2F);
    
    Color iconColor = Colors.grey.shade400;
    IconData iconData = Icons.radio_button_unchecked;
    
    if (isCompleted) {
      iconColor = primaryGreen;
      iconData = Icons.check_circle_rounded;
    } else if (isCurrent) {
      if (isError) {
        iconColor = errorColor;
        iconData = Icons.error_rounded;
      } else {
        iconColor = primaryGreen;
        iconData = Icons.radio_button_checked;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? primaryGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                color: (isCurrent || isCompleted) ? Colors.black87 : Colors.black38,
                fontSize: 16,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
