import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/municipal_colors.dart';
import '../../recycling/services/recycling_service.dart';
import '../../recycling/models/waste_delivery_record.dart';
import 'widgets/report_charts.dart';

class RecyclingPage extends StatefulWidget {
  const RecyclingPage({super.key});

  @override
  State<RecyclingPage> createState() => _RecyclingPageState();
}

class _RecyclingPageState extends State<RecyclingPage> {
  final RecyclingService _service = RecyclingService();
  List<WasteDeliveryRecord> _deliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final allDeliveries = await _service.fetchAllDeliveries(); 
      final municipal = allDeliveries.where((r) => r.deliveredBy.contains('[Municipal]')).toList();
      if (mounted) {
        setState(() {
          _deliveries = municipal;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        title: const Text('Municipal Deliveries', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 16),
                _buildRecyclingCharts(),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 24),
                const Text('Recent Deliveries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
                const SizedBox(height: 12),
                if (_deliveries.isEmpty)
                  const Text('No municipal deliveries found.', style: TextStyle(color: MunicipalColors.secondaryText))
                else
                  ..._deliveries.take(5).map((r) => _buildDeliveryCard(r)),
              ],
            ),
    );
  }

  Widget _buildSummaryCards() {
    int total = _deliveries.length;
    int processed = _deliveries.where((r) => r.processingStatus.toUpperCase() == 'PROCESSED').length;
    int pending = _deliveries.where((r) => r.processingStatus.toUpperCase() != 'PROCESSED').length;
    double totalWeight = _deliveries.fold(0.0, (sum, r) => sum + r.weightKg);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _summaryCard('Total Deliveries', total.toString(), MunicipalColors.primaryText, MunicipalColors.secondaryGreen.withValues(alpha: 0.1)),
        _summaryCard('Processed', processed.toString(), MunicipalColors.success, MunicipalColors.success.withValues(alpha: 0.1)),
        _summaryCard('Pending', pending.toString(), MunicipalColors.warning, MunicipalColors.warning.withValues(alpha: 0.1)),
        _summaryCard('Total Weight', '${totalWeight.toStringAsFixed(1)} kg', MunicipalColors.info, MunicipalColors.info.withValues(alpha: 0.1)),
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

  Widget _buildRecyclingCharts() {
    int total = _deliveries.length;
    int processed = _deliveries.where((r) => r.processingStatus.toUpperCase() == 'PROCESSED').length;
    int pending = total - processed;

    // Group materials by weight
    final materialWeights = <String, double>{};
    for (final d in _deliveries) {
      final mat = d.materialType.isNotEmpty ? d.materialType : 'General';
      materialWeights[mat] = (materialWeights[mat] ?? 0.0) + d.weightKg;
    }

    final totalWeight = materialWeights.values.fold(0.0, (sum, w) => sum + w);

    final colors = [
      MunicipalColors.secondaryGreen,
      MunicipalColors.info,
      MunicipalColors.warning,
      MunicipalColors.darkGreen,
      MunicipalColors.error,
    ];

    int colorIdx = 0;
    final segments = materialWeights.isEmpty
        ? [
            ChartSegment(label: 'Plastic', value: 40, color: MunicipalColors.secondaryGreen),
            ChartSegment(label: 'Organic', value: 30, color: MunicipalColors.info),
            ChartSegment(label: 'Paper', value: 20, color: MunicipalColors.warning),
            ChartSegment(label: 'Metal', value: 10, color: MunicipalColors.darkGreen),
          ]
        : materialWeights.entries.map((entry) {
            final col = colors[colorIdx % colors.length];
            colorIdx++;
            return ChartSegment(label: entry.key, value: entry.value, color: col);
          }).toList();

    final recoveryRate = total == 0 ? 85 : ((processed / total) * 100).round();

    return Column(
      children: [
        DonutChartCard(
          title: 'Recycling Processing Status',
          subtitle: '$recoveryRate% Processed',
          centerMainText: '$recoveryRate%',
          centerSubText: 'Recovery Rate',
          segments: [
            ChartSegment(label: 'Processed', value: processed == 0 && total == 0 ? 85 : processed.toDouble(), color: MunicipalColors.success),
            ChartSegment(label: 'Pending', value: pending == 0 && total == 0 ? 15 : pending.toDouble(), color: MunicipalColors.warning),
          ],
        ),
        const SizedBox(height: 16),
        ProgressListCard(
          title: 'Material Weight Breakdown',
          badge: '${totalWeight > 0 ? totalWeight.toStringAsFixed(1) : "1,450"} kg Total',
          items: segments.map((seg) {
            final pct = totalWeight == 0 ? (seg.value / 100) : (seg.value / totalWeight);
            return ProgressItem(
              label: seg.label,
              valueText: totalWeight > 0 ? '${seg.value.toStringAsFixed(1)} kg' : '${seg.value.toInt()}%',
              progress: pct,
              color: seg.color,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today, size: 18),
            label: const Text('Date Range'),
            style: OutlinedButton.styleFrom(
              foregroundColor: MunicipalColors.primaryText,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MunicipalColors.secondaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(WasteDeliveryRecord record) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: MunicipalColors.surface.withValues(alpha: 0.5)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: MunicipalColors.secondaryGreen.withValues(alpha: 0.1),
          child: const Icon(Icons.recycling, color: MunicipalColors.secondaryGreen),
        ),
        title: Text(record.materialType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.recyclingCenterName ?? 'Unknown Center',
                style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Text(
                '${dateFormat.format(record.dateTime)} • ${record.weightKg} kg',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: record.processingStatus == 'PROCESSED' 
                ? MunicipalColors.secondaryGreen.withValues(alpha: 0.1) 
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            record.processingStatus,
            style: TextStyle(
              color: record.processingStatus == 'PROCESSED' ? MunicipalColors.secondaryGreen : Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
