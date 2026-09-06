class CollectionScheduleItem {
  final String time;
  final String zone;
  final String type;
  final String status;

  CollectionScheduleItem({
    required this.time,
    required this.zone,
    required this.type,
    required this.status,
  });

  factory CollectionScheduleItem.fromJson(Map<String, dynamic> json) {
    return CollectionScheduleItem(
      time: json['time'] ?? '',
      zone: json['zone'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class ComplaintSummary {
  final String title;
  final String location;
  final String priority;
  final String timeAgo;

  ComplaintSummary({
    required this.title,
    required this.location,
    required this.priority,
    required this.timeAgo,
  });

  factory ComplaintSummary.fromJson(Map<String, dynamic> json) {
    return ComplaintSummary(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      priority: json['priority'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
    );
  }
}

class OperationsOverview {
  final int collectionsCompleted;
  final int collectionsTotal;
  final int trucksOnRoute;
  final int trucksTotal;
  final double wasteCollectedTons;
  final double wasteTotalTons;
  final double recyclingCollectedTons;
  final double recyclingTotalTons;

  OperationsOverview({
    required this.collectionsCompleted,
    required this.collectionsTotal,
    required this.trucksOnRoute,
    required this.trucksTotal,
    required this.wasteCollectedTons,
    required this.wasteTotalTons,
    required this.recyclingCollectedTons,
    required this.recyclingTotalTons,
  });

  factory OperationsOverview.fromJson(Map<String, dynamic> json) {
    return OperationsOverview(
      collectionsCompleted: json['collectionsCompleted'] ?? 0,
      collectionsTotal: json['collectionsTotal'] ?? 0,
      trucksOnRoute: json['trucksOnRoute'] ?? 0,
      trucksTotal: json['trucksTotal'] ?? 0,
      wasteCollectedTons: (json['wasteCollectedTons'] ?? 0.0).toDouble(),
      wasteTotalTons: (json['wasteTotalTons'] ?? 0.0).toDouble(),
      recyclingCollectedTons: (json['recyclingCollectedTons'] ?? 0.0).toDouble(),
      recyclingTotalTons: (json['recyclingTotalTons'] ?? 0.0).toDouble(),
    );
  }
}

class HotspotItem {
  final double lat;
  final double lng;
  final String priority;

  HotspotItem({
    required this.lat,
    required this.lng,
    required this.priority,
  });

  factory HotspotItem.fromJson(Map<String, dynamic> json) {
    return HotspotItem(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      priority: json['priority'] ?? 'LOW',
    );
  }
}

class MunicipalAnnouncement {
  final String title;
  final String description;
  final String date;
  final bool isNew;

  MunicipalAnnouncement({
    required this.title,
    required this.description,
    required this.date,
    required this.isNew,
  });

  factory MunicipalAnnouncement.fromJson(Map<String, dynamic> json) {
    return MunicipalAnnouncement(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      isNew: json['isNew'] ?? false,
    );
  }
}

class MunicipalDashboardSummary {
  final int totalCollectionsToday;
  final int activeCollectors;
  final int totalCollectors;
  final int pendingComplaints;
  final int highPriorityComplaints;
  final int recyclingRate;
  final List<CollectionScheduleItem> todaySchedules;
  final List<ComplaintSummary> recentComplaints;
  final OperationsOverview operationsOverview;
  final List<HotspotItem> hotspots;
  final List<MunicipalAnnouncement> announcements;
  final int activeAlerts;
  final int criticalAlerts;
  final int unassignedJobs;

  MunicipalDashboardSummary({
    required this.totalCollectionsToday,
    required this.activeCollectors,
    required this.totalCollectors,
    required this.pendingComplaints,
    required this.highPriorityComplaints,
    required this.recyclingRate,
    required this.todaySchedules,
    required this.recentComplaints,
    required this.operationsOverview,
    required this.hotspots,
    required this.announcements,
    required this.activeAlerts,
    required this.criticalAlerts,
    required this.unassignedJobs,
  });

  factory MunicipalDashboardSummary.fromJson(Map<String, dynamic> json) {
    return MunicipalDashboardSummary(
      totalCollectionsToday: json['totalCollectionsToday'] ?? 0,
      activeCollectors: json['activeCollectors'] ?? 0,
      totalCollectors: json['totalCollectors'] ?? 0,
      pendingComplaints: json['pendingComplaints'] ?? 0,
      highPriorityComplaints: json['highPriorityComplaints'] ?? 0,
      recyclingRate: json['recyclingRate'] ?? 0,
      todaySchedules: (json['todaySchedules'] as List? ?? [])
          .map((item) => CollectionScheduleItem.fromJson(item))
          .toList(),
      recentComplaints: (json['recentComplaints'] as List? ?? [])
          .map((item) => ComplaintSummary.fromJson(item))
          .toList(),
      operationsOverview: OperationsOverview.fromJson(
        json['operationsOverview'] ?? {},
      ),
      hotspots: (json['hotspots'] as List? ?? [])
          .map((item) => HotspotItem.fromJson(item))
          .toList(),
      announcements: (json['announcements'] as List? ?? [])
          .map((item) => MunicipalAnnouncement.fromJson(item))
          .toList(),
      activeAlerts: json['activeAlerts'] ?? 0,
      criticalAlerts: json['criticalAlerts'] ?? 0,
      unassignedJobs: json['unassignedJobs'] ?? 0,
    );
  }
}
