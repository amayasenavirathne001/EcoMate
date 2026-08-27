package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "waste_reports")
public class WasteReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 24)
    private String referenceNumber;

    @Column(nullable = false)
    private String reporterEmail;

    @Column(nullable = false, length = 80)
    private String issueType;

    @Column(nullable = false, length = 120)
    private String location;

    private Double latitude;
    private Double longitude;

    @Column(length = 80)
    private String wasteCategory;

    @Column(nullable = false, length = 1200)
    private String description;

    @Lob
    @Column(columnDefinition = "TEXT")
    private String photoData;

    @Column(nullable = false, length = 24)
    private String status;

    @Column(nullable = false, length = 16)
    private String priority;

    @Column(length = 80)
    private String assignedTeam;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    protected WasteReport() {
    }

    public WasteReport(String referenceNumber, String reporterEmail, String issueType,
                       String location, Double latitude, Double longitude,
                       String wasteCategory, String description, String photoData) {
        this.referenceNumber = referenceNumber;
        this.reporterEmail = reporterEmail;
        this.issueType = issueType;
        this.location = location;
        this.latitude = latitude;
        this.longitude = longitude;
        this.wasteCategory = wasteCategory;
        this.description = description;
        this.photoData = photoData;
        this.status = "SUBMITTED";
        this.priority = "MEDIUM";
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public String getReferenceNumber() { return referenceNumber; }
    public String getReporterEmail() { return reporterEmail; }
    public String getIssueType() { return issueType; }
    public String getLocation() { return location; }
    public Double getLatitude() { return latitude; }
    public Double getLongitude() { return longitude; }
    public String getWasteCategory() { return wasteCategory; }
    public String getDescription() { return description; }
    public String getPhotoData() { return photoData; }
    public String getStatus() { return status; }
    public String getPriority() { return priority; }
    public String getAssignedTeam() { return assignedTeam; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void updateAdminFields(String status, String priority, String assignedTeam) {
        this.status = status;
        this.priority = priority;
        this.assignedTeam = assignedTeam;
    }
}
