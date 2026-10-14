import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';
import 'widgets/report_charts.dart';

class MunicipalOperationsPage extends StatelessWidget {
  const MunicipalOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        title: const Text('Municipal Operations', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 16),
          DonutChartCard(
            title: 'Collection Performance',
            subtitle: '85% On-Time',
            centerMainText: '85%',
            centerSubText: 'Success Rate',
            segments: [
              ChartSegment(label: 'On-Time Completed', value: 85, color: MunicipalColors.success),
              ChartSegment(label: 'Delayed Jobs', value: 15, color: MunicipalColors.error),
            ],
          ),
          const SizedBox(height: 16),
          BarChartCard(
            title: 'Driver & Fleet Status',
            subtitle: '24 / 30 Active',
            maxY: 30,
            data: [
              BarGroup(label: 'Active', value: 24, color: MunicipalColors.secondaryGreen, displayValue: '24'),
              BarGroup(label: 'Standby', value: 4, color: MunicipalColors.info, displayValue: '4'),
              BarGroup(label: 'Repairs', value: 2, color: MunicipalColors.warning, displayValue: '2'),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _summaryCard('Total Jobs', '2,150', MunicipalColors.primaryText, MunicipalColors.secondaryGreen.withValues(alpha: 0.1)),
        _summaryCard('Completed', '1,820', MunicipalColors.success, MunicipalColors.success.withValues(alpha: 0.1)),
        _summaryCard('Delayed Jobs', '140', MunicipalColors.error, MunicipalColors.error.withValues(alpha: 0.1)),
        _summaryCard('Active Vehicles', '24', MunicipalColors.info, MunicipalColors.info.withValues(alpha: 0.1)),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.date_range),
            label: const Text('Date Range'),
            style: OutlinedButton.styleFrom(foregroundColor: MunicipalColors.primaryText, side: const BorderSide(color: MunicipalColors.border)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export Report'),
            style: FilledButton.styleFrom(backgroundColor: MunicipalColors.secondaryGreen),
          ),
        ),
      ],
    );
  }
}
