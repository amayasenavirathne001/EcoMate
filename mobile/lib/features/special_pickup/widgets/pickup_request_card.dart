import 'package:flutter/material.dart';
import '../models/pickup_request.dart';
import 'pickup_status_badge.dart';

class PickupRequestCard extends StatelessWidget {
  final PickupRequest request;
  final VoidCallback onViewDetails;

  const PickupRequestCard({
    super.key,
    required this.request,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime date) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PickupStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.wasteType,
            style: const TextStyle(
              color: Color(0xFF071A26),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, request.address),
          if (request.scheduledDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.schedule_rounded, 
              '${formatDate(request.scheduledDate!)} ${request.scheduledTime != null ? '• ${request.scheduledTime}' : ''}'
            ),
          ],
          if (request.collectorName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_outline_rounded, request.collectorName!),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewDetails,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0E8A38),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
