package com.ecomate.backend.specialpickup.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import com.ecomate.backend.specialpickup.enums.SpecialPickupStatus;

@Entity
@Table(name = "special_pickups")
public class SpecialPickup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "schedule_id")
    private SpecialPickupSchedule schedule;

    private String title;
    private String description;
    private String location;
    
    @Column(name = "service_area")
    private String serviceArea;

    @Column(name = "pickup_date")
    private LocalDate pickupDate;

    @Column(name = "start_time")
    private LocalTime startTime;

    @Column(name = "end_time")
    private LocalTime endTime;

    @Column(name = "join_deadline")
    private LocalDateTime joinDeadline;

    @Column(name = "max_households")
    private Integer maxHouseholds;

    @Column(name = "max_weight_kg")
    private Double maxWeightKg;

    @Column(name = "max_volume_m3")
    private Double maxVolumeM3;

    @Column(name = "current_estimated_weight_kg")
    private Double currentEstimatedWeightKg = 0.0;

    @Column(name = "current_estimated_volume_m3")
    private Double currentEstimatedVolumeM3 = 0.0;
    
    @Column(name = "joined_households")
    private Integer joinedHouseholds = 0;

    @Column(name = "accepted_waste_types")
    private String acceptedWasteTypes;

    @Column(name = "truck_id")
    private Long truckId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private SpecialPickupStatus status = SpecialPickupStatus.SCHEDULED;

    @Column(name = "created_by")
    private Long createdBy;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public SpecialPickup() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public SpecialPickupSchedule getSchedule() {
    return schedule;
    }

    public void setSchedule(SpecialPickupSchedule schedule) {
    this.schedule = schedule;
    }
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
    
    public Long getTruckId() { return truckId; }
    public void setTruckId(Long truckId) { this.truckId = truckId; }
    
    public SpecialPickupStatus getStatus() {
        return status;
    }

    public void setStatus(SpecialPickupStatus status) {
        this.status = status;
    }
    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
