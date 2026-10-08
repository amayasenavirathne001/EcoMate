import 'package:flutter/material.dart';
import '../models/pickup_request.dart';
import '../widgets/pickup_status_badge.dart';
import '../widgets/pickup_status_timeline.dart';

class PickupRequestDetailsScreen extends StatelessWidget {
  final PickupRequest request;

  const PickupRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime date) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    }
    String formatTime(DateTime date) {
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $ampm';
    }
    
    final Color background = const Color(0xFFFAFCFA);
    final Color darkText = const Color(0xFF071A26);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        title: Text(
          'Request Details',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        request.id,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PickupStatusBadge(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    request.wasteType,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.description,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Details Section
            const Text(
              'Pickup Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: request.address,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Submitted Date',
                    value: '${formatDate(request.submittedDate)} at ${formatTime(request.submittedDate)}',
                  ),
                  if (request.scheduledDate != null) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Scheduled For',
                      value: '${formatDate(request.scheduledDate!)} ${request.scheduledTime != null ? '(${request.scheduledTime})' : ''}',
                    ),
                  ],
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Assigned Collector',
                    value: request.collectorName ?? 'Not assigned yet',
                    valueColor: request.collectorName == null ? Colors.grey.shade500 : Colors.black87,
                  ),
                  if (request.notes != null && request.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.note_alt_outlined,
                      label: 'Notes',
                      value: request.notes!,
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Timeline Section
            const Text(
              'Status Tracking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: PickupStatusTimeline(currentStatus: request.status),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
