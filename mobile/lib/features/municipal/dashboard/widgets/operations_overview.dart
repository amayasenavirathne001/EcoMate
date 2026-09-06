import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/municipal_dashboard_models.dart';

class OperationsOverviewWidget extends StatelessWidget {
  final OperationsOverview overview;

  const OperationsOverviewWidget({
    super.key,
    required this.overview,
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
          // Header Row with Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Operations Overview",
                style: TextStyle(
                  color: MunicipalColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MunicipalColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Today",
                      style: TextStyle(
                        color: MunicipalColors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: MunicipalColors.secondaryText,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress items
          _buildProgressRow(
            label: "Collections Completed",
            current: overview.collectionsCompleted.toDouble(),
            total: overview.collectionsTotal.toDouble(),
            valueText: "${overview.collectionsCompleted} / ${overview.collectionsTotal}",
          ),
          const SizedBox(height: 18),
          _buildProgressRow(
            label: "Trucks On Route",
            current: overview.trucksOnRoute.toDouble(),
            total: overview.trucksTotal.toDouble(),
            valueText: "${overview.trucksOnRoute} / ${overview.trucksTotal}",
          ),
          const SizedBox(height: 18),
          _buildProgressRow(
            label: "Waste Collected",
            current: overview.wasteCollectedTons,
            total: overview.wasteTotalTons,
            valueText: "${overview.wasteCollectedTons} / ${overview.wasteTotalTons} tons",
          ),
          const SizedBox(height: 18),
          _buildProgressRow(
            label: "Recycling Collected",
            current: overview.recyclingCollectedTons,
            total: overview.recyclingTotalTons,
            valueText: "${overview.recyclingCollectedTons} / ${overview.recyclingTotalTons} tons",
          ),

          const SizedBox(height: 24),

          // Bottom alert green message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MunicipalColors.noticeGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.eco_outlined,
                  color: MunicipalColors.noticeGreen,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Great progress! Keep up the sustainable work.",
                    style: TextStyle(
                      color: MunicipalColors.noticeGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required String label,
    required double current,
    required double total,
    required String valueText,
  }) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: MunicipalColors.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valueText,
              style: const TextStyle(
                color: MunicipalColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: MunicipalColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(
              MunicipalColors.secondaryGreen,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
