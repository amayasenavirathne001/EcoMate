import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../dashboard/services/smart_alert_service.dart';
import '../../dashboard/models/smart_alert_model.dart';
import '../../../../services/notification_service.dart';
import 'live_operations_map_screen.dart';
import 'dart:async';

class SmartAlertsScreen extends StatefulWidget {
  final int initialTab;
  const SmartAlertsScreen({super.key, this.initialTab = 0});

  @override
  State<SmartAlertsScreen> createState() => _SmartAlertsScreenState();
}

class _SmartAlertsScreenState extends State<SmartAlertsScreen> with SingleTickerProviderStateMixin {
  final SmartAlertService _alertService = SmartAlertService();
  final NotificationService _notificationService = NotificationService();

  late TabController _tabController;
  List<SmartAlert> _alerts = [];
  List<Map<String, dynamic>> _userNotifications = [];
  bool _isLoading = true;
  bool _isLoadingNotifs = true;
  String _filter = 'All'; // All, Critical, Delayed, Resolved
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _fetchAlerts();
    _fetchNotifications();

    // Periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchAlerts(isRefresh: true);
      _fetchNotifications(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _fetchNotifications({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() => _isLoadingNotifs = true);
    }
    try {
      final notifs = await _notificationService.getMyNotifications();
      if (mounted) {
        setState(() {
          _userNotifications = notifs;
          _isLoadingNotifs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingNotifs = false);
      }
    }
  }

  Future<void> _markNotificationAsRead(int id, int index) async {
    if (_userNotifications[index]['read'] == true) return;
    setState(() {
      _userNotifications[index]['read'] = true;
    });
    await _notificationService.markAsRead(id);
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
    final unreadNotifsCount = _userNotifications.where((n) => n['read'] != true).length;

    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        title: const Text('Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: MunicipalColors.secondaryGreen,
          labelColor: MunicipalColors.secondaryGreen,
          unselectedLabelColor: MunicipalColors.secondaryText,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18),
                  const SizedBox(width: 6),
                  const Text('Smart Alerts'),
                  if (_filteredAlerts.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_filteredAlerts.length}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_outlined, size: 18),
                  const SizedBox(width: 6),
                  const Text('Updates & Drops'),
                  if (unreadNotifsCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MunicipalColors.secondaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadNotifsCount',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Smart Alerts
          Column(
            children: [
              _buildFilters(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
                    : _filteredAlerts.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: MunicipalColors.secondaryGreen,
                            onRefresh: () => _fetchAlerts(isRefresh: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredAlerts.length,
                              itemBuilder: (context, index) {
                                return _buildAlertCard(_filteredAlerts[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),

          // Tab 2: User Notifications (Recycling Processing & Activity)
          _isLoadingNotifs
              ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
              : _userNotifications.isEmpty
                  ? _buildEmptyNotifsState()
                  : RefreshIndicator(
                      color: MunicipalColors.secondaryGreen,
                      onRefresh: () => _fetchNotifications(isRefresh: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _userNotifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notif = _userNotifications[index];
                          final isRead = notif['read'] == true;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _markNotificationAsRead(notif['id'], index),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isRead ? Colors.white : const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isRead ? Colors.grey.shade200 : MunicipalColors.secondaryGreen.withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isRead 
                                            ? Colors.grey.shade100 
                                            : MunicipalColors.secondaryGreen.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isRead ? Icons.done_all_rounded : Icons.mark_email_unread_rounded,
                                        color: isRead ? Colors.grey : MunicipalColors.secondaryGreen,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  notif['title'] ?? 'Notification',
                                                  style: TextStyle(
                                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                                    fontSize: 14,
                                                    color: MunicipalColors.primaryText,
                                                  ),
                                                ),
                                              ),
                                              if (!isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: MunicipalColors.secondaryGreen,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif['message'] ?? '',
                                            style: const TextStyle(fontSize: 12.5, color: MunicipalColors.secondaryText),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatNotifDate(notif['dateTime']),
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotifsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 14),
          const Text(
            'No updates or notifications yet',
            style: TextStyle(fontSize: 16, color: MunicipalColors.secondaryText, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Recycling drop-off processing alerts will appear here.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatNotifDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
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
              selectedColor: MunicipalColors.secondaryGreen.withValues(alpha: 0.2),
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
                  _formatTimeAgo(alert.createdTimestamp),
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
