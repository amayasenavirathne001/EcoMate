import 'dart:convert';

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import '../../features/recycling/screens/waste_segregation_guide_screen.dart';
import '../../features/recycling/screens/recycling_centres_screen.dart';
import '../../features/recycling/screens/resident_recycling_history_screen.dart';
import '../collection_schedule_screen.dart';
import '../report_issue_screen.dart';
import '../my_reports_screen.dart';
import '../resident_profile_screen.dart';
import '../../features/recycling/screens/waste_segregation_guide_screen.dart';
import '../../features/recycling/screens/recycling_centres_screen.dart';
import '../../features/special_pickup/screens/pickup_requests_screen.dart';
import '../../features/special_pickup/screens/pickup_request_details_screen.dart';
import '../../features/special_pickup/data/pickup_mock_data.dart';
import '../../features/special_pickup/models/special_pickup.dart';
import '../../features/special_pickup/services/special_pickup_service.dart';
import '../../features/special_pickup/screens/join_special_pickup_screen.dart';
class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});
  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}
class _ResidentDashboardState extends State<ResidentDashboard> {
  final AuthService _authService = AuthService();
  final SpecialPickupService _specialPickupService = SpecialPickupService();

  int _selectedIndex = 0;
  String _userName = 'Resident';
  String? _profilePictureData;
  SpecialPickup? _specialPickup;
  bool _isLoadingSpecialPickup = true;
  String? _specialPickupError;
  static const Color darkText = Color(0xFF071A26);
  static const Color primaryGreen = Color(0xFF0E8A38);
  static const Color deepGreen = Color(0xFF006B4F);
  static const Color lightGreen = Color(0xFFEAF7E8);
  static const Color background = Color(0xFFFAFCFA);
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSpecialPickup();
  }
  Future<void> _loadUserInfo() async {
    try {
      final user = await _authService.getCurrentUser();
      if (!mounted) return;
      if (user != null) {
        final name = user['name']?.toString();
        final photo = (user['profilePictureData'] ?? user['profilePic'])?.toString();
        setState(() {
          if (name != null && name.trim().isNotEmpty) _userName = name.trim();
          _profilePictureData = photo?.isNotEmpty == true ? photo : null;
        });
      }
    } catch (_) {
      // Keep the fallback resident name.
    }
  }
  Future<void> _loadSpecialPickup() async {
    try {
      final pickups = await _specialPickupService.getAvailablePickups();
      if (!mounted) return;
      setState(() {
        _specialPickup = pickups.isNotEmpty ? pickups.first : null;
        _isLoadingSpecialPickup = false;
        _specialPickupError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _specialPickup = null;
        _isLoadingSpecialPickup = false;
        _specialPickupError = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
  void _openPickupRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PickupRequestsScreen()),
    );
  }
  void _openPickupDetails() {
    try {
      final request = mockPickupRequests.firstWhere(
        (request) => request.id == 'PR-1024',
        orElse: () => mockPickupRequests.first,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PickupRequestDetailsScreen(request: request),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pickup details are currently available.'),
        ),
      );
    }
  }
  void _openSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CollectionScheduleScreen()),
    );
  }
  void _openReportIssue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
    );
  }
  void _openActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyReportsScreen()),
    );
  }
  Future<void> _openProfile() async {
    setState(() => _selectedIndex = 4);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResidentProfileScreen()),
    );
    if (!mounted) return;
    setState(() => _selectedIndex = 0);
    await _loadUserInfo();
  }
  void _openRecyclingGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WasteSegregationGuideScreen()),
    );
  }
  void _onBottomNavTap(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    if (index == 1) {
      _openSchedule();
      return;
    }
    if (index == 2) {
      _openReportIssue();
      return;
    }
    if (index == 3) {
      _openActivity();
      return;
    }
    if (index == 4) {
      _openProfile();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 115),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildGreetingCard(),
                  const SizedBox(height: 14),
                  _buildWasteCategoryCard(),
                  const SizedBox(height: 16),
                  _buildSpecialPickupSection(),
                  const SizedBox(height: 20),
                  _sectionTitle(icon: Icons.bolt_rounded, title: 'Quick Actions'),
                  const SizedBox(height: 10),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildNextPickupCard(),
                  const SizedBox(height: 20),
                  _sectionTitle(icon: Icons.insights_rounded, title: 'Your Impact'),
                  const SizedBox(height: 10),
                  _buildStatsSection(),
                  const SizedBox(height: 20),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  Widget _buildNextPickupCard() {
  return InkWell(
    onTap: _openSchedule,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: _whiteCardDecoration(20),
      child: Row(
        children: [
          // Bin icon
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: Color(0xFF08795E),
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          // Pickup details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Next Pickup + badge
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Next Pickup',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF5D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Regular Pickup',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Thursday, 22 May 2025',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                // Time + Waste
                const Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: darkText,
                        ),
                        SizedBox(width: 7),
                        Text(
                          '6:00 AM - 9:00 AM',
                          style: TextStyle(
                            color: Color(0xFF566270),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 18,
                          color: primaryGreen,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'General Waste',
                          style: TextStyle(
                            color: Color(0xFF566270),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Location
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: darkText,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '123, Green Lane, Colombo 07',
                        style: TextStyle(
                          color: Color(0xFF566270),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          const Icon(
            Icons.chevron_right_rounded,
            color: darkText,
            size: 27,
          ),
        ],
      ),
    ),
  );
}
  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 82,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded, size: 32, color: darkText),
              ),
              const Spacer(),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco_rounded,
                            color: primaryGreen,
                            size: 36,
                          ),
                          const SizedBox(width: 5),
                          RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(
                              text: 'Eco',
                              style: TextStyle(color: darkText),
                            ),
                            TextSpan(
                              text: 'Mate',
                              style: TextStyle(color: deepGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Together for a Cleaner Tomorrow',
                    style: TextStyle(color: Colors.black54, fontSize: 9.5),
                  ),
                ],
              ),
            ),
          ), // Added comma here
          const Spacer(),
          Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No new notifications.')),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: darkText,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 3,
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 2),
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFF4D8D7C),
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'R',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // ============================================================
  // GREETING
  // ============================================================
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FFF7), Color(0xFFF1F9ED)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8EAD4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDEED8), width: 3),
            ),
            child: ClipOval(child: _buildResidentAvatar()),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_userName! Ã°Å¸â€˜â€¹',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'A cleaner neighborhood starts with you.',
                  maxLines: 2,
                  style: TextStyle(color: Color(0xFF40505D), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Eco Points',
                style: TextStyle(color: Colors.black54, fontSize: 11),
              ),
              const SizedBox(height: 2),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_rounded, color: primaryGreen, size: 19),
                  SizedBox(width: 4),
                  Text(
                    '1,250',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: darkText),
        ],
      ),
    );
  }
  Widget _buildResidentAvatar() {
    final photoData = _profilePictureData;
    if (photoData != null && photoData.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(photoData.split(',').last),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(Icons.eco_rounded, color: primaryGreen, size: 36),
        );
      } catch (_) {
        return const Icon(Icons.eco_rounded, color: primaryGreen, size: 36);
      }
    }
    return Image.asset(
      'assets/images/resident_profile.png',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.eco_rounded, color: primaryGreen, size: 36),
    );
  }
  // ============================================================
  // SPECIAL PICKUP
  // ============================================================
  Widget _buildSpecialPickupSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, color: deepGreen, size: 26),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Special Pickup Near You',
                  style: TextStyle(color: darkText, fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: _openPickupRequests,
                child: const Text('View All', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 34),
            child: Text(
              'Join existing special pickups in your neighborhood and help save fuel!',
              style: TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ),
          const SizedBox(height: 13),
          if (_isLoadingSpecialPickup)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator(color: primaryGreen)),
            )
          else if (_specialPickupError != null)
            _buildSpecialPickupError()
          else if (_specialPickup == null)
            _buildNoSpecialPickup()
          else
            _buildSpecialPickupContent(_specialPickup!),
        ],
      ),
    );
  }

  Widget _buildSpecialPickupError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD7D7)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 36),
          const SizedBox(height: 8),
          const Text('Could not load special pickups', style: TextStyle(color: darkText, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Check your connection and try again.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 11)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isLoadingSpecialPickup = true;
                _specialPickupError = null;
              });
              _loadSpecialPickup();
            },
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSpecialPickup() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      decoration: BoxDecoration(color: const Color(0xFFF5FAF5), borderRadius: BorderRadius.circular(15)),
      child: const Column(
        children: [
          Icon(Icons.local_shipping_outlined, color: primaryGreen, size: 42),
          SizedBox(height: 8),
          Text('No special pickups available', style: TextStyle(color: darkText, fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('New community pickups will appear here when they become available.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSpecialPickupContent(SpecialPickup pickup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            if (compact) {
              return Column(
                children: [
                  _pickupImage(pickup),
                  const SizedBox(height: 12),
                  _pickupDetails(pickup),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: constraints.maxWidth * 0.28, child: _pickupImage(pickup)),
                const SizedBox(width: 14),
                Expanded(child: _pickupDetails(pickup)),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.eco_rounded, color: primaryGreen, size: 18),
            const SizedBox(width: 7),
            const Expanded(
              child: Text('Same truck, cleaner city. Join and make an impact!', style: TextStyle(color: Colors.black54, fontSize: 10.5)),
            ),
            const SizedBox(width: 8),
            Icon(pickup.joinDeadlinePassed ? Icons.event_busy_rounded : Icons.schedule_rounded, size: 17, color: pickup.joinDeadlinePassed ? Colors.redAccent : darkText),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _joinDeadlineText(pickup),
                textAlign: TextAlign.right,
                style: TextStyle(color: pickup.joinDeadlinePassed ? Colors.redAccent : darkText, fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pickupImage(SpecialPickup pickup) {
    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(15)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/special_pickup.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFE8F4E7),
              child: const Icon(Icons.local_shipping_rounded, size: 65, color: primaryGreen),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: deepGreen.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.groups_rounded, color: Colors.white, size: 15),
                  const SizedBox(width: 4),
                  Text('${pickup.joinedHouseholds}/${pickup.maxHouseholds} joined', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickupDetails(SpecialPickup pickup) {
    final joined = pickup.isApproved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: joined ? const Color(0xFFDDF5D9) : pickup.canJoin ? const Color(0xFFCFF8D3) : const Color(0xFFFFF0D8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(joined ? Icons.check_circle_rounded : pickup.canJoin ? Icons.add_circle_outline_rounded : Icons.info_outline_rounded, size: 14, color: joined ? deepGreen : pickup.canJoin ? primaryGreen : const Color(0xFFB86500)),
              const SizedBox(width: 4),
              Text(joined ? 'JOINED' : pickup.canJoin ? 'JOINABLE' : 'UNAVAILABLE', style: TextStyle(color: joined ? deepGreen : pickup.canJoin ? primaryGreen : const Color(0xFFB86500), fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(pickup.title, style: const TextStyle(color: darkText, fontSize: 17, fontWeight: FontWeight.w800)),
        if (pickup.description.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(pickup.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 10.5)),
        ],
        const SizedBox(height: 10),
        _pickupLine(Icons.calendar_month_outlined, _formatPickupDate(pickup.pickupDate)),
        _pickupLine(Icons.schedule_rounded, '${_formatTime(pickup.startTime)} - ${_formatTime(pickup.endTime)}'),
        _pickupLine(Icons.location_on_outlined, pickup.location.isNotEmpty ? pickup.location : pickup.serviceArea),
        _pickupLine(Icons.eco_outlined, pickup.acceptedWasteTypes.isEmpty ? 'Accepted waste types not specified' : pickup.acceptedWasteTypes.join(', ')),
        const SizedBox(height: 5),
        _buildHouseholdCapacity(pickup),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _showPickupSummary(pickup),
              style: OutlinedButton.styleFrom(foregroundColor: deepGreen, side: const BorderSide(color: Color(0xFFD5DEDA)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
              child: const Text('View Details'),
            ),
            if (joined) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(11)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: primaryGreen, size: 17),
                    SizedBox(width: 5),
                    Text('Joined', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ] else if (pickup.canJoin) ...[
              const SizedBox(width: 8),
             ElevatedButton.icon(
              onPressed: () async {
                final joined = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinSpecialPickupScreen(
                      pickup: pickup,
                    ),
                  ),
                );

                if (joined == true) {
                  await _loadSpecialPickup();
                }
              },
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 17,
              ),
              label: const Text('Join'),
              style: ElevatedButton.styleFrom(
                backgroundColor: deepGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHouseholdCapacity(SpecialPickup pickup) {
    final progress = pickup.maxHouseholds <= 0 ? 0.0 : (pickup.joinedHouseholds / pickup.maxHouseholds).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Households', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${pickup.joinedHouseholds} / ${pickup.maxHouseholds}', style: const TextStyle(color: darkText, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: const Color(0xFFE8ECEA), valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen)),
        ),
      ],
    );
  }

  String _formatPickupDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String value) {
    try {
      final parts = value.split(':');
      if (parts.length < 2) return value;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final suffix = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
    } catch (_) {
      return value;
    }
  }

  String _joinDeadlineText(SpecialPickup pickup) {
    final deadline = pickup.joinDeadline;
    if (deadline == null) return 'Join while space is available';
    final now = DateTime.now();
    if (now.isAfter(deadline)) return 'Joining closed';
    final difference = deadline.difference(now);
    if (difference.inDays > 0) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} left';
    }
    if (difference.inHours > 0) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} left';
    }
    return 'Less than 1 hour left';
  }

  void _showPickupSummary(SpecialPickup pickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 18),
                Text(pickup.title, style: const TextStyle(color: darkText, fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(pickup.description, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 18),
                _pickupLine(Icons.calendar_month_outlined, _formatPickupDate(pickup.pickupDate)),
                _pickupLine(Icons.schedule_rounded, '${_formatTime(pickup.startTime)} - ${_formatTime(pickup.endTime)}'),
                _pickupLine(Icons.location_on_outlined, pickup.location),
                _pickupLine(Icons.map_outlined, pickup.serviceArea),
                _pickupLine(Icons.eco_outlined, pickup.acceptedWasteTypes.join(', ')),
                const SizedBox(height: 10),
                Text('Households: ${pickup.joinedHouseholds}/${pickup.maxHouseholds}'),
                const SizedBox(height: 6),
                Text('Remaining weight: ${pickup.remainingWeightKg.toStringAsFixed(1)} kg'),
                const SizedBox(height: 6),
                Text('Remaining volume: ${pickup.remainingVolumeM3.toStringAsFixed(1)} mÃ‚Â³'),
                if (pickup.isApproved) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(13)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: primaryGreen),
                        SizedBox(width: 8),
                        Expanded(child: Text('You have joined this special pickup.', style: TextStyle(color: deepGreen, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pickupLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: darkText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF4F5B66), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // QUICK ACTIONS
  // ============================================================
  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: darkText, size: 24),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
  Widget _buildQuickActions() {
    final actions = [
      (
        icon: Icons.calendar_month_rounded,
        title: 'View\nSchedule',
        color: const Color(0xFF08795E),
        background: const Color(0xFFE8F5EB),
        onTap: _openSchedule,
      ),
      (
        icon: Icons.local_shipping_rounded,
        title: 'Special\nPickup',
        color: const Color(0xFF158A62),
        background: const Color(0xFFEEF8EC),
        onTap: _openPickupRequests,
      ),
      (
        icon: Icons.warning_amber_rounded,
        title: 'Report\nIssue',
        color: const Color(0xFFFF7100),
        background: const Color(0xFFFFF0D8),
        onTap: _openReportIssue,
      ),
      (
        icon: Icons.recycling_rounded,
        title: 'Recycling\nGuide',
        color: const Color(0xFF36A64B),
        background: const Color(0xFFEEF8E8),
        onTap: _openRecyclingGuide,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.0;
        final width = (constraints.maxWidth - (spacing * 3)) / 4;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              SizedBox(
                width: width,
                child: _quickAction(
                  icon: actions[i].icon,
                  title: actions[i].title,
                  color: actions[i].color,
                  background: actions[i].background,
                  onTap: actions[i].onTap,
                ),
              ),
              if (i != actions.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
  Widget _quickAction({
    required IconData icon,
    required String title,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 31),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: darkText,
                fontSize: 11.5,
                height: 1.15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // TODAY'S WASTE
  // ============================================================
  Widget _buildWasteCategoryCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005B43), Color(0xFF087358), Color(0xFF155D49)],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 4, 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Waste Category",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Organic Waste',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Keep it green!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Only organic waste today in your area.',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: _openRecyclingGuide,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'View Guide',
                        style: TextStyle(fontSize: 10.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/images/organic_waste_bin.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              errorBuilder: (_, _, _) {
                return const Icon(
                  Icons.delete_rounded,
                  color: Colors.white70,
                  size: 90,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // STATISTICS
  // ============================================================
  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 9.0;
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final cards = [
          _statCard(
            icon: Icons.recycling_rounded,
            value: '45',
            title: 'Items Recycled',
            subtitle: 'This Month',
            footer: '? 12% vs last month',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResidentRecyclingHistoryScreen()),
              );
            },
          ),
          _statCard(
            icon: Icons.local_shipping_rounded,
            value: '3',
            title: 'Pickup Requests',
            subtitle: 'This Month',
            footer: '? 2 Completed',
          ),
          _statCard(
            icon: Icons.groups_rounded,
            value: '12',
            title: 'Active Neighbors',
            subtitle: 'In Your Area',
            footer: '? 2 joined this week',
          ),
          _statCard(
            icon: Icons.eco_rounded,
            value: '1,250',
            title: 'Community Score',
            subtitle: 'Great job!',
            footer: '? Top 20% in your area',
          ),
        ];
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
    required String footer,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(12),
        decoration: _whiteCardDecoration(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: lightGreen,
                child: Icon(icon, color: primaryGreen, size: 21),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            style: const TextStyle(
              color: darkText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 10.5),
          ),
          const SizedBox(height: 10),
          Text(
            footer,
            maxLines: 2,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    );
  }
  // ============================================================
  // RECENT ACTIVITY
  // ============================================================
  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
      decoration: _whiteCardDecoration(20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: darkText, size: 23),
              const SizedBox(width: 8),
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _openActivity,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          _activityItem(
            icon: Icons.local_shipping_rounded,
            title: 'Pickup Completed',
            category: 'Organic Waste',
            date: '16 May 2025 Ã¢â‚¬Â¢ 7:15 AM',
            completed: true,
            onTap: _openPickupDetails,
          ),
          const Divider(height: 1),
          _activityItem(
            icon: Icons.description_rounded,
            title: 'Request Submitted',
            category: 'Recyclables',
            date: '14 May 2025 Ã¢â‚¬Â¢ 4:30 PM',
            completed: false,
            onTap: _openPickupRequests,
          ),
        ],
      ),
    );
  }
  Widget _activityItem({
    required IconData icon,
    required String title,
    required String category,
    required String date,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: lightGreen,
              child: Icon(icon, color: primaryGreen, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.black45, fontSize: 10),
                  ),
                ],
              ),
            ),
            Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: completed ? primaryGreen : Colors.black45,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // DRAWER
  // ============================================================
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco_rounded, color: primaryGreen, size: 31),
                SizedBox(width: 5),
                Text(
                  'EcoMate',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _drawerItem(
              Icons.home_rounded,
              'Home',
              () => Navigator.pop(context),
            ),
            _drawerItem(Icons.calendar_month_outlined, 'Schedule', () {
              Navigator.pop(context);
              _openSchedule();
            }),
            _drawerItem(Icons.local_shipping_outlined, 'Pickup Requests', () {
              Navigator.pop(context);
              _openPickupRequests();
            }),
            _drawerItem(Icons.warning_amber_rounded, 'Report Issue', () {
              Navigator.pop(context);
              _openReportIssue();
            }),
            _drawerItem(Icons.recycling_rounded, 'Recycling Guide', () {
              Navigator.pop(context);
              _openRecyclingGuide();
            }),
            _drawerItem(Icons.storefront_outlined, 'Recycling Centers', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecyclingCentresScreen(),
                ),
              );
            }),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomItem(0, Icons.home_rounded, 'Home'),
              _bottomItem(1, Icons.calendar_month_outlined, 'Schedule'),
              GestureDetector(
                onTap: _openReportIssue,
                child: Transform.translate(
                  offset: const Offset(0, -15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 61,
                        height: 61,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10A85B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 13,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Report',
                        style: TextStyle(color: Colors.black54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              _bottomItem(3, Icons.description_outlined, 'Activity'),
              _bottomItem(4, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _bottomItem(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onBottomNavTap(index),
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? primaryGreen : Colors.black45,
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? primaryGreen : Colors.black45,
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // COMMON DECORATION
  // ============================================================
  BoxDecoration _whiteCardDecoration(double radius) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.045),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}




