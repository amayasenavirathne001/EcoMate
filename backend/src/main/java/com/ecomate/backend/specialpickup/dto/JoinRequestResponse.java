package com.ecomate.backend.specialpickup.dto;

import java.time.LocalDateTime;

public class JoinRequestResponse {

    private Long id;
    private Long specialPickupId;
    private String pickupTitle;

    private Long residentId;
    private String residentName;

    private String wasteType;
    private Integer numberOfItems;
    private String estimatedSize;

    private Double estimatedWeightKg;
    private Double estimatedVolumeM3;

    private String pickupAddress;
    private String notes;
    private String photoUrl;

    private String status;
    private String adminReason;

    private LocalDateTime createdAt;
    private LocalDateTime approvedAt;

    public JoinRequestResponse() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getSpecialPickupId() {
        return specialPickupId;
    }

    public void setSpecialPickupId(Long specialPickupId) {
        this.specialPickupId = specialPickupId;
    }

    public String getPickupTitle() {
        return pickupTitle;
    }

    public void setPickupTitle(String pickupTitle) {
        this.pickupTitle = pickupTitle;
    }

    public Long getResidentId() {
        return residentId;
    }

    public void setResidentId(Long residentId) {
        this.residentId = residentId;
    }

    public String getResidentName() {
        return residentName;
    }

    public void setResidentName(String residentName) {
        this.residentName = residentName;
    }

    public String getWasteType() {
        return wasteType;
    }

    public void setWasteType(String wasteType) {
        this.wasteType = wasteType;
    }

    public Integer getNumberOfItems() {
        return numberOfItems;
    }

    public void setNumberOfItems(Integer numberOfItems) {
        this.numberOfItems = numberOfItems;
    }

    public String getEstimatedSize() {
        return estimatedSize;
    }

    public void setEstimatedSize(String estimatedSize) {
        this.estimatedSize = estimatedSize;
    }

    public Double getEstimatedWeightKg() {
        return estimatedWeightKg;
    }

    public void setEstimatedWeightKg(Double estimatedWeightKg) {
        this.estimatedWeightKg = estimatedWeightKg;
    }

    public Double getEstimatedVolumeM3() {
        return estimatedVolumeM3;
    }

    public void setEstimatedVolumeM3(Double estimatedVolumeM3) {
        this.estimatedVolumeM3 = estimatedVolumeM3;
    }

    public String getPickupAddress() {
        return pickupAddress;
    }

    public void setPickupAddress(String pickupAddress) {
        this.pickupAddress = pickupAddress;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdminReason() {
        return adminReason;
    }

    public void setAdminReason(String adminReason) {
        this.adminReason = adminReason;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }
}