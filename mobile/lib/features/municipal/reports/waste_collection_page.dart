import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';
import 'widgets/report_charts.dart';

class WasteCollectionPage extends StatelessWidget {
  const WasteCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        title: const Text('Waste Collection', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 16),
          DonutChartCard(
            title: 'Collection Performance',
            subtitle: '92% Success Rate',
            centerMainText: '92%',
            centerSubText: 'Completion',
            segments: [
              ChartSegment(label: 'Completed', value: 985, color: MunicipalColors.success),
              ChartSegment(label: 'Pending', value: 230, color: MunicipalColors.warning),
              ChartSegment(label: 'Delayed', value: 25, color: MunicipalColors.error),
            ],
          ),
          const SizedBox(height: 16),
          BarChartCard(
            title: 'Area-wise Collection (Requests)',
            subtitle: 'Total 1,240',
            maxY: 500,
            data: [
              BarGroup(label: 'Zone A', value: 450, color: MunicipalColors.secondaryGreen, displayValue: '450'),
              BarGroup(label: 'Zone B', value: 320, color: MunicipalColors.info, displayValue: '320'),
              BarGroup(label: 'Zone C', value: 280, color: MunicipalColors.darkGreen, displayValue: '280'),
              BarGroup(label: 'Zone D', value: 190, color: MunicipalColors.warning, displayValue: '190'),
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
        _summaryCard('Total Requests', '1,240', MunicipalColors.primaryText, MunicipalColors.secondaryGreen.withValues(alpha: 0.1)),
        _summaryCard('Completed', '985', MunicipalColors.success, MunicipalColors.success.withValues(alpha: 0.1)),
        _summaryCard('Pending', '230', MunicipalColors.warning, MunicipalColors.warning.withValues(alpha: 0.1)),
        _summaryCard('Delayed', '25', MunicipalColors.error, MunicipalColors.error.withValues(alpha: 0.1)),
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
