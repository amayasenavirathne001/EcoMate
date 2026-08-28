import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../../features/municipal/operations/models/operations_models.dart';
import '../../features/municipal/operations/services/operations_service.dart';
import '../../features/municipal/theme/municipal_colors.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  final AuthService _authService = AuthService();
  final OperationsService _operationsService = OperationsService();

  String _employeeName = '';
  String _employeeId = 'EMP-001'; // Default test employee ID for seeded John Doe
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCollectorData();
  }

  Future<void> _loadCollectorData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _employeeName = user['name'] ?? 'John Doe';
          // Match test accounts
          if (_employeeName.toLowerCase().contains('john') || _employeeName.toLowerCase().contains('doe')) {
            _employeeId = 'EMP-001';
          } else if (_employeeName.toLowerCase().contains('jane')) {
            _employeeId = 'EMP-002';
          } else if (_employeeName.toLowerCase().contains('bob')) {
            _employeeId = 'EMP-003';
          } else if (_employeeName.toLowerCase().contains('alice')) {
            _employeeId = 'EMP-004';
          }
        });
      }

      // Fetch notifications
      final notifications = await _operationsService.getNotifications(_employeeId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(int notificationId) async {
    try {
      await _operationsService.markNotificationAsRead(notificationId);
      // Reload notifications locally
      _loadCollectorData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: MunicipalColors.secondaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Collector Portal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MunicipalColors.secondaryGreen))
          : RefreshIndicator(
              onRefresh: _loadCollectorData,
              color: MunicipalColors.secondaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Profile Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [MunicipalColors.secondaryGreen, MunicipalColors.darkGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WELCOME BACK,',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _employeeName.isNotEmpty ? _employeeName : 'John Doe',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'ID: $_employeeId',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Duty: Driver / Collector',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Notification List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, color: MunicipalColors.secondaryGreen),
                            const SizedBox(width: 8),
                            const Text(
                              'Duty & Route Assignments',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                            ),
                          ],
                        ),
                        Text(
                          '${_notifications.where((n) => !n.read).length} new',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MunicipalColors.secondaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_errorMessage.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(_errorMessage, style: const TextStyle(color: MunicipalColors.error)),
                        ),
                      )
                    else if (_notifications.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: MunicipalColors.border),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, color: MunicipalColors.secondaryText, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'No route assignments yet.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You will be notified when you are assigned to a route.',
                              style: TextStyle(color: MunicipalColors.secondaryText, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ..._notifications.map((notif) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notif.read ? Colors.white : const Color(0xFFEDF8F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: notif.read ? MunicipalColors.border : MunicipalColors.secondaryGreen.withValues(alpha: 0.3),
                              width: notif.read ? 1 : 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: notif.read ? MunicipalColors.primaryText : MunicipalColors.secondaryGreen,
                                      ),
                                    ),
                                  ),
                                  if (!notif.read)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 30),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => _markRead(notif.id!),
                                      child: const Text('Mark Read', style: TextStyle(fontSize: 12, color: MunicipalColors.secondaryGreen, fontWeight: FontWeight.bold)),
                                    )
                                  else
                                    const Icon(Icons.check_circle_outline_rounded, color: Colors.grey, size: 18),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.message,
                                style: const TextStyle(fontSize: 13, color: MunicipalColors.primaryText, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${notif.dateTime.hour.toString().padLeft(2, '0')}:${notif.dateTime.minute.toString().padLeft(2, '0')} on ${notif.dateTime.month}/${notif.dateTime.day}',
                                style: const TextStyle(fontSize: 11, color: MunicipalColors.secondaryText),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}