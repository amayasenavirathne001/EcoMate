package com.ecomate.backend.service;

import com.ecomate.backend.dto.*;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class MunicipalDashboardService {

    private final com.ecomate.backend.repository.SmartAlertRepository alertRepository;

    public MunicipalDashboardService(com.ecomate.backend.repository.SmartAlertRepository alertRepository) {
        this.alertRepository = alertRepository;
    }

    public MunicipalDashboardResponse getDashboardData() {
        // Today's Schedules
        List<ScheduleItemDto> schedules = new ArrayList<>();
        schedules.add(new ScheduleItemDto("06:00 AM", "Zone A – Greenfield", "Residential Collection", "In Progress"));
        schedules.add(new ScheduleItemDto("10:00 AM", "Zone B – Lakeview", "Mixed Waste Collection", "Upcoming"));
        schedules.add(new ScheduleItemDto("02:00 PM", "Zone C – Riverside", "Commercial Collection", "Upcoming"));

        // Recent Complaints
        List<ComplaintSummaryDto> complaints = new ArrayList<>();
        complaints.add(new ComplaintSummaryDto("Overflowing Bin", "Lakeview Street, Sector 7", "High", "20m ago"));
        complaints.add(new ComplaintSummaryDto("Missed Collection", "Greenfield Avenue, Block B", "Medium", "1h ago"));
        complaints.add(new ComplaintSummaryDto("Illegal Dumping", "Riverside Park, Gate 3", "Low", "2h ago"));

        // Operations Overview
        OperationsOverviewDto overview = new OperationsOverviewDto(
            128, 160,
            34, 50,
            42.6, 60.0,
            30.7, 60.0
        );

        // Hotspots
        List<HotspotDto> hotspots = new ArrayList<>();
        hotspots.add(new HotspotDto(6.9271, 79.8612, "HIGH"));
        hotspots.add(new HotspotDto(6.9285, 79.8650, "MEDIUM"));
        hotspots.add(new HotspotDto(6.9250, 79.8630, "LOW"));

        // Announcements
        List<AnnouncementDto> announcements = new ArrayList<>();
        announcements.add(new AnnouncementDto(
            "City Clean Drive – This Weekend",
            "All zones are requested to ensure timely collections and public awareness. Let's keep our city clean and green!",
            "May 16, 2025",
            true
        ));

        List<com.ecomate.backend.entity.SmartAlert> activeAlertList = alertRepository.findByStatusNot(com.ecomate.backend.entity.AlertStatus.RESOLVED);
        int activeAlertsCount = activeAlertList.size();
        int criticalAlertsCount = (int) activeAlertList.stream().filter(a -> a.getSeverity() == com.ecomate.backend.entity.AlertSeverity.CRITICAL).count();
        int unassignedJobsCount = (int) activeAlertList.stream().filter(a -> a.getType() == com.ecomate.backend.entity.AlertType.UNASSIGNED_COLLECTION).count();

        return new MunicipalDashboardResponse(
            128,
            34,
            68,
            18,
            5,
            72,
            schedules,
            complaints,
            overview,
            hotspots,
            announcements,
            activeAlertsCount,
            criticalAlertsCount,
            unassignedJobsCount
        );
    }
}
