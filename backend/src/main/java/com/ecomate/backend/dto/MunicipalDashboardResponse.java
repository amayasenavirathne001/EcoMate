package com.ecomate.backend.dto;

import java.util.List;

public record MunicipalDashboardResponse(
    int totalCollectionsToday,
    int activeCollectors,
    int totalCollectors,
    int pendingComplaints,
    int highPriorityComplaints,
    int recyclingRate,
    List<ScheduleItemDto> todaySchedules,
    List<ComplaintSummaryDto> recentComplaints,
    OperationsOverviewDto operationsOverview,
    List<HotspotDto> hotspots,
    List<AnnouncementDto> announcements,
    int activeAlerts,
    int criticalAlerts,
    int unassignedJobs
) {}
