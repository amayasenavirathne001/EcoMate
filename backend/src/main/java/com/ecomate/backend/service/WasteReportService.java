package com.ecomate.backend.service;

import com.ecomate.backend.dto.CreateWasteReportRequest;
import com.ecomate.backend.dto.WasteReportResponse;
import com.ecomate.backend.dto.UpdateWasteReportRequest;
import com.ecomate.backend.entity.WasteReport;
import com.ecomate.backend.repository.WasteReportRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;

@Service
public class WasteReportService {
    private final WasteReportRepository repository;

    public WasteReportService(WasteReportRepository repository) {
        this.repository = repository;
    }

    public WasteReportResponse create(String reporterEmail, CreateWasteReportRequest request) {
        String reference = "RPT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        WasteReport report = new WasteReport(reference, reporterEmail, request.issueType(),
                request.location(), request.latitude(), request.longitude(), request.wasteCategory(),
                request.description(), request.photoData());
        return WasteReportResponse.from(repository.save(report));
    }

    public List<WasteReportResponse> findMine(String reporterEmail) {
        return repository.findByReporterEmailOrderByCreatedAtDesc(reporterEmail)
                .stream().map(WasteReportResponse::from).toList();
    }

    public List<WasteReportResponse> findAll() {
        return repository.findAllByOrderByCreatedAtDesc()
                .stream().map(WasteReportResponse::from).toList();
    }

    public WasteReportResponse update(Long id, UpdateWasteReportRequest request) {
        WasteReport report = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Report not found"));
        report.updateAdminFields(request.status(), request.priority(), request.assignedTeam());
        return WasteReportResponse.from(repository.save(report));
    }
}
