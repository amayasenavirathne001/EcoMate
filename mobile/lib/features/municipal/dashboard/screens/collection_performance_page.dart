import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';

class CollectionPerformancePage extends StatefulWidget {
  const CollectionPerformancePage({super.key});

  @override
  State<CollectionPerformancePage> createState() => _CollectionPerformancePageState();
}

class _CollectionPerformancePageState extends State<CollectionPerformancePage> {
  String _selectedFilter = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        title: const Text('Collection Performance', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilter(),
            const SizedBox(height: 24),
            _buildPerformanceSummary(),
            const SizedBox(height: 24),
            _buildCollectionCompletion(),
            const SizedBox(height: 24),
            _buildCollectionStatus(),
            const SizedBox(height: 24),
            _buildAreaPerformance(),
            const SizedBox(height: 24),
            _buildRecentJobs(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: MunicipalColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: ['Today', 'This Week', 'This Month'].map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? MunicipalColors.secondaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MunicipalColors.secondaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    // Mock data varying by filter
    int total = _selectedFilter == 'Today' ? 128 : (_selectedFilter == 'This Week' ? 890 : 3800);
    int completed = _selectedFilter == 'Today' ? 96 : (_selectedFilter == 'This Week' ? 700 : 3400);
    int pending = _selectedFilter == 'Today' ? 18 : (_selectedFilter == 'This Week' ? 100 : 250);
    int delayed = _selectedFilter == 'Today' ? 14 : (_selectedFilter == 'This Week' ? 90 : 150);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performance Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Total', total.toString(), MunicipalColors.primaryText, MunicipalColors.surface)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Completed', completed.toString(), MunicipalColors.success, MunicipalColors.success.withValues(alpha: 0.1))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Pending', pending.toString(), MunicipalColors.warning, MunicipalColors.warning.withValues(alpha: 0.1))),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Delayed', delayed.toString(), MunicipalColors.error, MunicipalColors.error.withValues(alpha: 0.1))),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCollectionCompletion() {
    int total = _selectedFilter == 'Today' ? 128 : (_selectedFilter == 'This Week' ? 890 : 3800);
    int completed = _selectedFilter == 'Today' ? 96 : (_selectedFilter == 'This Week' ? 700 : 3400);
    double percentage = total == 0 ? 0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Collection Completion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MunicipalColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$completed of $total completed', style: const TextStyle(fontSize: 14, color: MunicipalColors.secondaryText)),
                  Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MunicipalColors.secondaryGreen)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: MunicipalColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(MunicipalColors.secondaryGreen),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Collection Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatusIndicator('Completed', MunicipalColors.success),
            const SizedBox(width: 8),
            _buildStatusIndicator('Pending', MunicipalColors.warning),
            const SizedBox(width: 8),
            _buildStatusIndicator('Delayed', MunicipalColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaPerformance() {
    final areas = [
      {'name': 'Malabe', 'completed': 32, 'pending': 4, 'delayed': 2},
      {'name': 'Kaduwela', 'completed': 27, 'pending': 5, 'delayed': 3},
      {'name': 'Kottawa', 'completed': 21, 'pending': 3, 'delayed': 5},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Area Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
        const SizedBox(height: 12),
        ...areas.map((area) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MunicipalColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(area['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAreaStat('Completed', area['completed'] as int, MunicipalColors.success),
                  _buildAreaStat('Pending', area['pending'] as int, MunicipalColors.warning),
                  _buildAreaStat('Delayed', area['delayed'] as int, MunicipalColors.error),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAreaStat(String label, int value, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
        Text(value.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildRecentJobs() {
    final jobs = [
      {'area': 'Malabe', 'time': '12 Sep, 10:30 AM', 'driver': 'Kasun', 'vehicle': 'Truck 04', 'status': 'COMPLETED'},
      {'area': 'Kaduwela', 'time': '12 Sep, 11:15 AM', 'driver': 'Nimal', 'vehicle': 'Truck 02', 'status': 'DELAYED'},
      {'area': 'Kottawa', 'time': '12 Sep, 12:00 PM', 'driver': 'Saman', 'vehicle': 'Truck 05', 'status': 'PENDING'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Collection Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
        const SizedBox(height: 12),
        ...jobs.map((job) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MunicipalColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: MunicipalColors.surface, shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping_outlined, color: MunicipalColors.secondaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['area']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
                    const SizedBox(height: 4),
                    Text(job['time']!, style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
                    const SizedBox(height: 4),
                    Text('Driver: ${job['driver']} • Vehicle: ${job['vehicle']}', style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
                  ],
                ),
              ),
              _buildJobStatus(job['status']!),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildJobStatus(String status) {
    Color color;
    if (status == 'COMPLETED') color = MunicipalColors.success;
    else if (status == 'DELAYED') color = MunicipalColors.error;
    else color = MunicipalColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
