package com.ecomate.backend.service;

import com.ecomate.backend.dto.CreateWasteReportRequest;
import com.ecomate.backend.dto.WasteReportResponse;
import com.ecomate.backend.dto.UpdateWasteReportRequest;
import com.ecomate.backend.dto.WasteReportSummary;
import com.ecomate.backend.dto.UpdateResidentWasteReportRequest;
import com.ecomate.backend.dto.WasteReportFeedbackRequest;
import com.ecomate.backend.entity.WasteReport;
import com.ecomate.backend.repository.WasteReportRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;
import java.util.Map;
import java.util.Set;

@Service
public class WasteReportService {
    private final WasteReportRepository repository;
    private final NotificationService notificationService;

    public WasteReportService(WasteReportRepository repository, NotificationService notificationService) {
        this.repository = repository;
        this.notificationService = notificationService;
    }

    public WasteReportResponse create(String reporterEmail, CreateWasteReportRequest request) {
        String reference = "RPT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        WasteReport report = new WasteReport(reference, reporterEmail, request.issueType(),
                request.location(), request.latitude(), request.longitude(), request.wasteCategory(),
                request.description(), request.photoData());
        return WasteReportResponse.from(repository.save(report));
    }

    public List<WasteReportResponse> findMine(String reporterEmail) {
        return repository.findSummariesByReporterEmailOrderByCreatedAtDesc(reporterEmail)
            .stream().map(WasteReportSummary::toResponse).toList();
    }

    public List<WasteReportResponse> findAll() {
        return repository.findAllSummariesByOrderByCreatedAtDesc()
            .stream().map(WasteReportSummary::toResponse).toList();
    }

    public WasteReportResponse update(Long id, UpdateWasteReportRequest request) {
        WasteReport report = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Report not found"));
        validateTransition(report.getStatus(), request.status(), request.assignedTeam());
        String previousStatus = report.getStatus();
        report.updateAdminFields(request.status(), request.priority(), request.assignedTeam(),
            request.reviewNotes(), request.resolutionEvidence());
        WasteReportResponse response = WasteReportResponse.from(repository.save(report));
        if (!previousStatus.equals(request.status())) {
            notificationService.createUserNotification(report.getReporterEmail(), "Report status updated",
                "Report " + report.getReferenceNumber() + " is now " + request.status().replace('_', ' ').toLowerCase() + ".");
        }
        return response;
    }

    public WasteReportResponse updateMine(String reporterEmail, Long id,
                                          UpdateResidentWasteReportRequest request) {
        WasteReport report = repository.findByIdAndReporterEmail(id, reporterEmail)
                .orElseThrow(() -> new IllegalArgumentException("Report not found for the current user"));
        report.updateResidentFields(request.issueType(), request.location(),
            request.wasteCategory(), request.description(), request.latitude(),
            request.longitude(), request.photoData());
        return WasteReportResponse.from(repository.save(report));
    }

    public void deleteMine(String reporterEmail, Long id) {
        WasteReport report = repository.findByIdAndReporterEmail(id, reporterEmail)
                .orElseThrow(() -> new IllegalArgumentException("Report not found for the current user"));
        repository.delete(report);
    }

    public WasteReportResponse addFeedback(String reporterEmail, Long id, WasteReportFeedbackRequest request) {
        WasteReport report = repository.findByIdAndReporterEmail(id, reporterEmail)
                .orElseThrow(() -> new IllegalArgumentException("Report not found for the current user"));
        if (!"RESOLVED".equals(report.getStatus())) {
            throw new IllegalArgumentException("Feedback is available after the report is resolved");
        }
        report.addReporterFeedback(request.feedback());
        return WasteReportResponse.from(repository.save(report));
    }

    private void validateTransition(String current, String next, String assignedTeam) {
        Set<String> allowed = Set.of("SUBMITTED", "IN_REVIEW", "ASSIGNED", "RESOLVED", "REJECTED");
        if (!allowed.contains(next)) {
            throw new IllegalArgumentException("Unsupported report status: " + next);
        }
        Map<String, Set<String>> blocked = Map.of(
                "SUBMITTED", Set.of("RESOLVED"),
                "IN_REVIEW", Set.of("SUBMITTED"),
                "ASSIGNED", Set.of("SUBMITTED"),
                "RESOLVED", Set.of("IN_REVIEW", "SUBMITTED"),
                "REJECTED", Set.of("IN_REVIEW", "SUBMITTED", "ASSIGNED", "RESOLVED"));
        if (blocked.getOrDefault(current, Set.of()).contains(next)) {
            throw new IllegalArgumentException("Status cannot move from " + current + " to " + next);
        }
        if (("IN_REVIEW".equals(next) || "ASSIGNED".equals(next))
                && (assignedTeam == null || assignedTeam.isBlank())) {
            throw new IllegalArgumentException("An assigned team is required before moving to " + next);
        }
    }
}
