import 'package:flutter/material.dart';
import '../models/pickup_request.dart';

class PickupStatusBadge extends StatelessWidget {
  final PickupStatus status;

  const PickupStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case PickupStatus.submitted:
        text = 'SUBMITTED';
        backgroundColor = const Color(0xFFF0F0F0);
        textColor = const Color(0xFF555555);
        break;
      case PickupStatus.approved:
        text = 'APPROVED';
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case PickupStatus.scheduled:
        text = 'SCHEDULED';
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case PickupStatus.collectorAssigned:
        text = 'COLLECTOR ASSIGNED';
        backgroundColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57F17);
        break;
      case PickupStatus.inProgress:
        text = 'IN PROGRESS';
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case PickupStatus.completed:
        text = 'COMPLETED';
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF1B5E20);
        break;
      case PickupStatus.rejected:
        text = 'REJECTED';
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      case PickupStatus.failed:
        text = 'FAILED';
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFB71C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
