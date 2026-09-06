import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../dashboard/services/smart_alert_service.dart';
import '../../dashboard/models/smart_alert_model.dart';
import 'live_operations_map_screen.dart';
import 'dart:async';

class SmartAlertsScreen extends StatefulWidget {
  const SmartAlertsScreen({super.key});

  @override
  State<SmartAlertsScreen> createState() => _SmartAlertsScreenState();
}

class _SmartAlertsScreenState extends State<SmartAlertsScreen> {
  final SmartAlertService _alertService = SmartAlertService();
  List<SmartAlert> _alerts = [];
  bool _isLoading = true;
  String _filter = 'All'; // All, Critical, Delayed, Resolved
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
    // Periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchAlerts(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAlerts({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() => _isLoading = true);
    }
    
    try {
      final alerts = await _alertService.getAllAlerts();
      if (mounted) {
        setState(() {
          _alerts = alerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    await _alertService.updateAlertStatus(id, newStatus);
    _fetchAlerts();
  }

  List<SmartAlert> get _filteredAlerts {
    if (_filter == 'Critical') {
      return _alerts.where((a) => a.severity == 'CRITICAL' && a.status != 'RESOLVED').toList();
    } else if (_filter == 'Delayed') {
      return _alerts.where((a) => a.type == 'DELAYED_COLLECTION' && a.status != 'RESOLVED').toList();
    } else if (_filter == 'Resolved') {
      return _alerts.where((a) => a.status == 'RESOLVED').toList();
    }
    return _alerts.where((a) => a.status != 'RESOLVED').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        title: const Text('Smart Alerts & Delays'),
        backgroundColor: Colors.white,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
                : _filteredAlerts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAlerts.length,
                        itemBuilder: (context, index) {
                          return _buildAlertCard(_filteredAlerts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: ['All', 'Critical', 'Delayed', 'Resolved'].map((filter) {
          final isSelected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _filter = filter);
                }
              },
              selectedColor: MunicipalColors.secondaryGreen.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? MunicipalColors.secondaryGreen : MunicipalColors.secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No $_filter alerts found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(SmartAlert alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert.severity) {
      case 'CRITICAL':
        severityColor = MunicipalColors.error;
        severityIcon = Icons.error_outline;
        break;
      case 'WARNING':
        severityColor = const Color(0xFFF59E0B);
        severityIcon = Icons.warning_amber_rounded;
        break;
      default:
        severityColor = MunicipalColors.secondaryGreen;
        severityIcon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(severityIcon, color: severityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.type.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: MunicipalColors.primaryText,
                    ),
                  ),
                ),
                Text(
                  '${_formatTimeAgo(alert.createdTimestamp)}',
                  style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: const TextStyle(fontSize: 14, color: MunicipalColors.secondaryText),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (alert.routeId != null) ...[
                  const Icon(Icons.route, size: 16, color: MunicipalColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(alert.routeId!, style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
                  const SizedBox(width: 16),
                ],
                if (alert.zone != null) ...[
                  const Icon(Icons.location_on_outlined, size: 16, color: MunicipalColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(alert.zone!, style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText)),
                ],
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Open Map
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LiveOperationsMapScreen()),
                    );
                  },
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('View on Map'),
                  style: TextButton.styleFrom(foregroundColor: MunicipalColors.secondaryGreen),
                ),
                if (alert.status != 'RESOLVED')
                  PopupMenuButton<String>(
                    onSelected: (value) => _updateStatus(alert.id, value),
                    itemBuilder: (context) => [
                      if (alert.status != 'ACKNOWLEDGED')
                        const PopupMenuItem(value: 'ACKNOWLEDGED', child: Text('Acknowledge')),
                      const PopupMenuItem(value: 'RESOLVED', child: Text('Resolve')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: MunicipalColors.secondaryGreen),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        alert.status,
                        style: const TextStyle(color: MunicipalColors.secondaryGreen, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
