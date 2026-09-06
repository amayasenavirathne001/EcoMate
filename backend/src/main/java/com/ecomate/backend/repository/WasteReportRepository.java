package com.ecomate.backend.repository;

import com.ecomate.backend.entity.WasteReport;
import com.ecomate.backend.dto.WasteReportSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface WasteReportRepository extends JpaRepository<WasteReport, Long> {
    @Query("""
            select new com.ecomate.backend.dto.WasteReportSummary(
                r.id, r.referenceNumber, r.issueType, r.location, r.latitude,
                r.longitude, r.wasteCategory, r.description,
                case when r.photoData is not null and r.photoData <> '' then true else false end,
                r.status, r.priority, r.assignedTeam, r.reporterEmail, r.createdAt)
            from WasteReport r
            where r.reporterEmail = :reporterEmail
            order by r.createdAt desc
            """)
    List<WasteReportSummary> findSummariesByReporterEmailOrderByCreatedAtDesc(String reporterEmail);

    @Query("""
            select new com.ecomate.backend.dto.WasteReportSummary(
                r.id, r.referenceNumber, r.issueType, r.location, r.latitude,
                r.longitude, r.wasteCategory, r.description,
                case when r.photoData is not null and r.photoData <> '' then true else false end,
                r.status, r.priority, r.assignedTeam, r.reporterEmail, r.createdAt)
            from WasteReport r
            order by r.createdAt desc
            """)
    List<WasteReportSummary> findAllSummariesByOrderByCreatedAtDesc();

    Optional<WasteReport> findByIdAndReporterEmail(Long id, String reporterEmail);
}
