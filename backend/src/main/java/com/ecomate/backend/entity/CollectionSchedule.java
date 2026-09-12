package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "collection_schedules")
public class CollectionSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String scheduleName;

    @ManyToOne(optional = false)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    @Column(nullable = false)
    private String areaOrZone;

    @ManyToOne(optional = false)
    @JoinColumn(name = "waste_category_id", nullable = false)
    private WasteCategory wasteCategory;

    @Column(nullable = false)
    private String collectionDateOrDay; // Date or Day name

    @Column(nullable = false)
    private String startTime;

    @Column(nullable = false)
    private String endTime;

    @Column(nullable = false)
    private String frequency; // One Time, Daily, Weekly, Custom

    @Column(nullable = false)
    private String destinationType; // Municipal Disposal Site, Recycling Centre

    @ManyToOne
    @JoinColumn(name = "recycling_center_id", nullable = true)
    private RecyclingCenter recyclingCenter;

    @Column(nullable = false)
    private String status = "ACTIVE"; // ACTIVE, INACTIVE

    @Column(nullable = false)
    private String resourceStatus = "Not Assigned"; // Assigned, Not Assigned

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public CollectionSchedule() {
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getScheduleName() {
        return scheduleName;
    }

    public void setScheduleName(String scheduleName) {
        this.scheduleName = scheduleName;
    }

    public Route getRoute() {
        return route;
    }

    public void setRoute(Route route) {
        this.route = route;
    }

    public String getAreaOrZone() {
        return areaOrZone;
    }

    public void setAreaOrZone(String areaOrZone) {
        this.areaOrZone = areaOrZone;
    }

    public WasteCategory getWasteCategory() {
        return wasteCategory;
    }

    public void setWasteCategory(WasteCategory wasteCategory) {
        this.wasteCategory = wasteCategory;
    }

    public String getCollectionDateOrDay() {
        return collectionDateOrDay;
    }

    public void setCollectionDateOrDay(String collectionDateOrDay) {
        this.collectionDateOrDay = collectionDateOrDay;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getFrequency() {
        return frequency;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public String getDestinationType() {
        return destinationType;
    }

    public void setDestinationType(String destinationType) {
        this.destinationType = destinationType;
    }

    public RecyclingCenter getRecyclingCenter() {
        return recyclingCenter;
    }

    public void setRecyclingCenter(RecyclingCenter recyclingCenter) {
        this.recyclingCenter = recyclingCenter;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResourceStatus() {
        return resourceStatus;
    }

    public void setResourceStatus(String resourceStatus) {
        this.resourceStatus = resourceStatus;
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
