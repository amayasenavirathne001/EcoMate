package com.ecomate.backend.specialpickup.dto;

import java.time.DayOfWeek;
import java.time.LocalTime;

public class SpecialPickupScheduleRequest {

    private Long routeId;
    private DayOfWeek dayOfWeek;
    private LocalTime startTime;
    private LocalTime endTime;

    // Household participation
    private Integer minHouseholds;
    private Integer maxHouseholds;

    // Capacity
    private Double maxWeightKg;
    private Double maxVolumeM3;

    // Join rules
    private Integer joinDeadlineHours;
    private String acceptedWasteTypes;

    public SpecialPickupScheduleRequest() {
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
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

    public Integer getMinHouseholds() {
        return minHouseholds;
    }

    public void setMinHouseholds(Integer minHouseholds) {
        this.minHouseholds = minHouseholds;
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
}