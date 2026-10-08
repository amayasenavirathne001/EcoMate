package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "waste_deliveries")
public class WasteDelivery {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recycling_center_id")
    private RecyclingCenter recyclingCenter;

    @Column(name = "material_type", nullable = false)
    private String materialType;

    @Column(name = "weight_kg", nullable = false)
    private Double weightKg;

    @Column(name = "delivered_by", nullable = false)
    private String deliveredBy;

    @Column(name = "contact_number")
    private String contactNumber;

    @Column(name = "date_time")
    private LocalDateTime dateTime;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "processing_status")
    private String processingStatus = "RECEIVED";

    @Column(name = "awarded_points")
    private Integer awardedPoints = 0;

    public WasteDelivery() {
        this.dateTime = LocalDateTime.now();
    }

    public WasteDelivery(RecyclingCenter recyclingCenter, String materialType, Double weightKg,
                         String deliveredBy, String contactNumber, LocalDateTime dateTime, String notes) {
        this.recyclingCenter = recyclingCenter;
        this.materialType = materialType;
        this.weightKg = weightKg;
        this.deliveredBy = deliveredBy;
        this.contactNumber = contactNumber;
        this.dateTime = dateTime != null ? dateTime : LocalDateTime.now();
        this.notes = notes;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public RecyclingCenter getRecyclingCenter() {
        return recyclingCenter;
    }

    public void setRecyclingCenter(RecyclingCenter recyclingCenter) {
        this.recyclingCenter = recyclingCenter;
    }

    public String getMaterialType() {
        return materialType;
    }

    public void setMaterialType(String materialType) {
        this.materialType = materialType;
    }

    public Double getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(Double weightKg) {
        this.weightKg = weightKg;
    }

    public String getDeliveredBy() {
        return deliveredBy;
    }

    public void setDeliveredBy(String deliveredBy) {
        this.deliveredBy = deliveredBy;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public LocalDateTime getDateTime() {
        return dateTime;
    }

    public void setDateTime(LocalDateTime dateTime) {
        this.dateTime = dateTime;
    }

    public String getProcessingStatus() { return processingStatus; }
    public void setProcessingStatus(String processingStatus) { this.processingStatus = processingStatus; }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Integer getAwardedPoints() { return awardedPoints; }
    public void setAwardedPoints(Integer awardedPoints) { this.awardedPoints = awardedPoints; }
}
