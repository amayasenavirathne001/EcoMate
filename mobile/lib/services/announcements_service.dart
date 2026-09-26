import 'package:flutter/foundation.dart';

class Announcement {
  final String id;
  String title;
  String message;
  String type;
  String priority;
  String targetAudience;
  String? targetArea;
  DateTime startDate;
  DateTime? expiryDate;
  String status;
  DateTime? publishedDate;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.targetAudience,
    this.targetArea,
    required this.startDate,
    this.expiryDate,
    required this.status,
    this.publishedDate,
  });
}

class AnnouncementsService extends ChangeNotifier {
  static final AnnouncementsService _instance = AnnouncementsService._internal();

  factory AnnouncementsService() {
    return _instance;
  }

  AnnouncementsService._internal() {
    // Add a dummy announcement for testing
    _announcements.add(
      Announcement(
        id: 'dummy-1',
        title: 'Collection Delayed in Zone A',
        message: 'Due to heavy traffic, waste collection in Zone A will be delayed by 2 hours today.',
        type: 'Collection Update',
        priority: 'Important',
        targetAudience: 'All Residents',
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'Published',
        publishedDate: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );
  }

  final List<Announcement> _announcements = [];

  List<Announcement> get allAnnouncements => List.unmodifiable(_announcements);

  List<Announcement> getPublishedAnnouncementsForResident() {
    return _announcements.where((a) {
      if (a.status != 'Published') return false;
      if (a.expiryDate != null && a.expiryDate!.isBefore(DateTime.now())) return false;
      // Residents should see announcements meant for "All Residents" or "Residents in Selected Area"
      return a.targetAudience == 'All Residents' || a.targetAudience == 'Residents in Selected Area';
    }).toList();
  }

  void addAnnouncement(Announcement announcement) {
    _announcements.add(announcement);
    notifyListeners();
  }

  void updateAnnouncement(Announcement updatedAnnouncement) {
    final index = _announcements.indexWhere((a) => a.id == updatedAnnouncement.id);
    if (index != -1) {
      _announcements[index] = updatedAnnouncement;
      notifyListeners();
    }
  }

  void deleteAnnouncement(String id) {
    _announcements.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
