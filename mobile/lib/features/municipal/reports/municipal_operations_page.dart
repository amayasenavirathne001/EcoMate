import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';

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
        _buildChartPlaceholder('Collection Performance', 'On-time: 85%, Delayed: 15%'),
        const SizedBox(height: 16),
        _buildChartPlaceholder('Driver/Vehicle Performance', 'Active Vehicles: 24/30'),
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
        _summaryCard('Total Jobs', '2,150', MunicipalColors.primaryText, MunicipalColors.secondaryGreen.withOpacity(0.1)),
        _summaryCard('Completed', '1,820', MunicipalColors.success, MunicipalColors.success.withOpacity(0.1)),
        _summaryCard('Delayed Jobs', '140', MunicipalColors.error, MunicipalColors.error.withOpacity(0.1)),
        _summaryCard('Active Vehicles', '24', MunicipalColors.info, MunicipalColors.info.withOpacity(0.1)),
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

  Widget _buildChartPlaceholder(String title, String subtitle) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MunicipalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text('$subtitle\n(Mock Data Chart)', textAlign: TextAlign.center, style: const TextStyle(color: MunicipalColors.mutedText)),
            ),
          ),
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
