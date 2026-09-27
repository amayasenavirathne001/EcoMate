package com.ecomate.backend.specialpickup.entity;

import com.ecomate.backend.entity.Route;
import jakarta.persistence.*;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "special_pickup_schedules")
public class SpecialPickupSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // =========================================================
    // ROUTE
    // =========================================================

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    // =========================================================
    // RECURRING PICKUP DAY / TIME
    // =========================================================

    @Enumerated(EnumType.STRING)
    @Column(name = "day_of_week", nullable = false)
    private DayOfWeek dayOfWeek;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    // =========================================================
    // CAPACITY
    // =========================================================

    @Column(name = "max_households", nullable = false)
    private Integer maxHouseholds;

    @Column(name = "max_weight_kg", nullable = false)
    private Double maxWeightKg;

    @Column(name = "max_volume_m3", nullable = false)
    private Double maxVolumeM3;

    // =========================================================
    // JOIN RULES
    // =========================================================

    /*
     * Example:
     * 12 means residents must join at least
     * 12 hours before the pickup starts.
     */
    @Column(name = "join_deadline_hours", nullable = false)
    private Integer joinDeadlineHours;

    /*
     * Store accepted waste types as comma-separated values.
     *
     * Example:
     * Furniture,Electronic Waste,Bulky Waste
     *
     * This matches the current SpecialPickup design.
     */
    @Column(name = "accepted_waste_types", length = 1000)
    private String acceptedWasteTypes;

    // =========================================================
    // STATUS
    // =========================================================

    @Column(nullable = false)
    private Boolean active = true;

    // =========================================================
    // AUDIT
    // =========================================================

    @Column(name = "created_by")
    private Long createdBy;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // =========================================================
    // JPA CALLBACKS
    // =========================================================

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();

        if (active == null) {
            active = true;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // =========================================================
    // CONSTRUCTOR
    // =========================================================

    public SpecialPickupSchedule() {
    }

    // =========================================================
    // GETTERS AND SETTERS
    // =========================================================

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Route getRoute() {
        return route;
    }

    public void setRoute(Route route) {
        this.route = route;
    }

    public DayOfWeek getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(DayOfWeek dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public Integer getMaxHouseholds() {
        return maxHouseholds;
    }

    public void setMaxHouseholds(Integer maxHouseholds) {
        this.maxHouseholds = maxHouseholds;
    }

    public Double getMaxWeightKg() {
        return maxWeightKg;
    }

    public void setMaxWeightKg(Double maxWeightKg) {
        this.maxWeightKg = maxWeightKg;
    }

    public Double getMaxVolumeM3() {
        return maxVolumeM3;
    }

    public void setMaxVolumeM3(Double maxVolumeM3) {
        this.maxVolumeM3 = maxVolumeM3;
    }

    public Integer getJoinDeadlineHours() {
        return joinDeadlineHours;
    }

    public void setJoinDeadlineHours(Integer joinDeadlineHours) {
        this.joinDeadlineHours = joinDeadlineHours;
    }

    public String getAcceptedWasteTypes() {
        return acceptedWasteTypes;
    }

    public void setAcceptedWasteTypes(String acceptedWasteTypes) {
        this.acceptedWasteTypes = acceptedWasteTypes;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}