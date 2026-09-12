import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';

class RecyclingPage extends StatelessWidget {
  const RecyclingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        title: const Text('Recycling', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildChartPlaceholder('Quantity by Material Category', 'Plastic: 40%, Paper: 30%, Glass: 20%, Metal: 10%'),
        const SizedBox(height: 16),
        _buildChartPlaceholder('Monthly Recycling Trend', 'Up by 15% this month'),
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
        _summaryCard('Total Recycled', '4,520 kg', MunicipalColors.primaryText, MunicipalColors.secondaryGreen.withOpacity(0.1)),
        _summaryCard('Activities', '156', MunicipalColors.info, MunicipalColors.info.withOpacity(0.1)),
        _summaryCard('Categories', '8', MunicipalColors.warning, MunicipalColors.warning.withOpacity(0.1)),
        _summaryCard('Top Area', 'North Zone', MunicipalColors.success, MunicipalColors.success.withOpacity(0.1)),
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
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
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
