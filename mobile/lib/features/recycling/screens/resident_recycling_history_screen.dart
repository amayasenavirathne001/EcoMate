import 'package:flutter/material.dart';

import '../models/waste_delivery_record.dart';
import '../models/material_item.dart';
import '../services/recycling_service.dart';

class ResidentRecyclingHistoryScreen extends StatefulWidget {
  const ResidentRecyclingHistoryScreen({super.key});

  @override
  State<ResidentRecyclingHistoryScreen> createState() => _ResidentRecyclingHistoryScreenState();
}

class _ResidentRecyclingHistoryScreenState extends State<ResidentRecyclingHistoryScreen> {
  final RecyclingService _service = RecyclingService();
  
  late Future<List<WasteDeliveryRecord>> _historyFuture;
  late List<MaterialItem> _masterMaterials;
  
  double _totalRecycledKg = 0.0;
  int _totalEcoPoints = 0;

  static const Color darkText = Color(0xFF071A26);
  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color background = Color(0xFFFAFCFA);
  static const Color cardBorder = Color(0xFFE5F2EE);

  @override
  void initState() {
    super.initState();
    _masterMaterials = _service.getMasterMaterialList();
    _historyFuture = _loadHistory();
  }

  Future<List<WasteDeliveryRecord>> _loadHistory() async {
    final records = await _service.fetchMyRecyclingHistory();
    
    double totalKg = 0;
    int totalPts = 0;
    
    for (var r in records) {
      totalKg += r.weightKg;
      totalPts += r.ecoPoints;
    }
    
    if (mounted) {
      setState(() {
        _totalRecycledKg = totalKg;
        _totalEcoPoints = totalPts;
      });
    }
    
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Recycling History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<WasteDeliveryRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryGreen));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load history.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            );
          }

          final records = snapshot.data ?? [];
          
          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: () async {
              setState(() {
                _historyFuture = _loadHistory();
              });
              await _historyFuture;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 20),
                const Text(
                  'Recent Drop-offs',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...records.map((r) => _buildHistoryCard(r)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006247), Color(0xFF007458)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL RECYCLED',
                  style: TextStyle(
                    color: Color(0xFFCBE6B6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalRecycledKg.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ECO POINTS',
                  style: TextStyle(
                    color: Color(0xFFCBE6B6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalEcoPoints',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(WasteDeliveryRecord record) {
    final isConfirmed = true; 
    final d = record.dateTime;
    final dateStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} • ${d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour)}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.recycling_rounded, color: primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.materialType,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.recyclingCentreName ?? 'Unknown Center',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${record.weightKg.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: cardBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? primaryGreen.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isConfirmed ? 'CONFIRMED' : 'PENDING',
                  style: TextStyle(
                    color: isConfirmed ? primaryGreen : Colors.orange.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: primaryGreen.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text(
            'No History Yet',
            style: TextStyle(
              color: darkText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your recycling drop-offs will appear here\nafter you visit a center.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }
}

