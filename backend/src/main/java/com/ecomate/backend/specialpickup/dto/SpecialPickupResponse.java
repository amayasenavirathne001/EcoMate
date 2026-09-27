package com.ecomate.backend.specialpickup.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class SpecialPickupResponse {
    private Long id;
    private String title;
    private String description;
    private String location;
    private String serviceArea;
    private LocalDate pickupDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private LocalDateTime joinDeadline;
    private Integer maxHouseholds;
    private Double maxWeightKg;
    private Double maxVolumeM3;
    private Double currentEstimatedWeightKg;
    private Double currentEstimatedVolumeM3;
    private Integer joinedHouseholds;
    private String acceptedWasteTypes;
    private String status;
    private String userJoinStatus; // PENDING_APPROVAL, APPROVED, REJECTED, null

    public SpecialPickupResponse() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getServiceArea() { return serviceArea; }
    public void setServiceArea(String serviceArea) { this.serviceArea = serviceArea; }

    public LocalDate getPickupDate() { return pickupDate; }
    public void setPickupDate(LocalDate pickupDate) { this.pickupDate = pickupDate; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }

    public LocalDateTime getJoinDeadline() { return joinDeadline; }
    public void setJoinDeadline(LocalDateTime joinDeadline) { this.joinDeadline = joinDeadline; }

    public Integer getMaxHouseholds() { return maxHouseholds; }
    public void setMaxHouseholds(Integer maxHouseholds) { this.maxHouseholds = maxHouseholds; }

    public Double getMaxWeightKg() { return maxWeightKg; }
    public void setMaxWeightKg(Double maxWeightKg) { this.maxWeightKg = maxWeightKg; }

    public Double getMaxVolumeM3() { return maxVolumeM3; }
    public void setMaxVolumeM3(Double maxVolumeM3) { this.maxVolumeM3 = maxVolumeM3; }

    public Double getCurrentEstimatedWeightKg() { return currentEstimatedWeightKg; }
    public void setCurrentEstimatedWeightKg(Double currentEstimatedWeightKg) { this.currentEstimatedWeightKg = currentEstimatedWeightKg; }

    public Double getCurrentEstimatedVolumeM3() { return currentEstimatedVolumeM3; }
    public void setCurrentEstimatedVolumeM3(Double currentEstimatedVolumeM3) { this.currentEstimatedVolumeM3 = currentEstimatedVolumeM3; }

    public Integer getJoinedHouseholds() { return joinedHouseholds; }
    public void setJoinedHouseholds(Integer joinedHouseholds) { this.joinedHouseholds = joinedHouseholds; }

    public String getAcceptedWasteTypes() { return acceptedWasteTypes; }
    public void setAcceptedWasteTypes(String acceptedWasteTypes) { this.acceptedWasteTypes = acceptedWasteTypes; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getUserJoinStatus() { return userJoinStatus; }
    public void setUserJoinStatus(String userJoinStatus) { this.userJoinStatus = userJoinStatus; }
}
