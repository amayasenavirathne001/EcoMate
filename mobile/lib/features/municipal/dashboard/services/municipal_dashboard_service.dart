import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/auth_service.dart';
import '../models/municipal_dashboard_models.dart';

class MunicipalDashboardService {
  final AuthService _authService = AuthService();
  static const String baseUrl = AuthService.baseUrl;

  Future<MunicipalDashboardSummary> getDashboardSummary() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/municipal/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MunicipalDashboardSummary.fromJson(data);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      // Graceful fallback to Mock Data if backend is down
      return getMockDashboardSummary();
    }
  }

  MunicipalDashboardSummary getMockDashboardSummary() {
    return MunicipalDashboardSummary(
      totalCollectionsToday: 128,
      activeCollectors: 34,
      totalCollectors: 68,
      pendingComplaints: 18,
      highPriorityComplaints: 5,
      recyclingRate: 72,
      todaySchedules: [
        CollectionScheduleItem(
          time: '06:00 AM',
          zone: 'Zone A – Greenfield',
          type: 'Residential Collection',
          status: 'In Progress',
        ),
        CollectionScheduleItem(
          time: '10:00 AM',
          zone: 'Zone B – Lakeview',
          type: 'Mixed Waste Collection',
          status: 'Upcoming',
        ),
        CollectionScheduleItem(
          time: '02:00 PM',
          zone: 'Zone C – Riverside',
          type: 'Commercial Collection',
          status: 'Upcoming',
        ),
      ],
      recentComplaints: [
        ComplaintSummary(
          title: 'Overflowing Bin',
          location: 'Lakeview Street, Sector 7',
          priority: 'High',
          timeAgo: '20m ago',
        ),
        ComplaintSummary(
          title: 'Missed Collection',
          location: 'Greenfield Avenue, Block B',
          priority: 'Medium',
          timeAgo: '1h ago',
        ),
        ComplaintSummary(
          title: 'Illegal Dumping',
          location: 'Riverside Park, Gate 3',
          priority: 'Low',
          timeAgo: '2h ago',
        ),
      ],
      operationsOverview: OperationsOverview(
        collectionsCompleted: 128,
        collectionsTotal: 160,
        trucksOnRoute: 34,
        trucksTotal: 50,
        wasteCollectedTons: 42.6,
        wasteTotalTons: 60.0,
        recyclingCollectedTons: 30.7,
        recyclingTotalTons: 60.0,
      ),
      hotspots: [
        HotspotItem(lat: 6.9271, lng: 79.8612, priority: 'HIGH'),
        HotspotItem(lat: 6.9285, lng: 79.8650, priority: 'MEDIUM'),
        HotspotItem(lat: 6.9250, lng: 79.8630, priority: 'LOW'),
      ],
      announcements: [
        MunicipalAnnouncement(
          title: 'City Clean Drive – This Weekend',
          description: 'All zones are requested to ensure timely collections and public awareness. Let\'s keep our city clean and green!',
          date: 'May 16, 2025',
          isNew: true,
        ),
      ],
      activeAlerts: 4,
      criticalAlerts: 2,
      unassignedJobs: 1,
    );
  }
}
