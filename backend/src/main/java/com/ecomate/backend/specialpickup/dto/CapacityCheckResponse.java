package com.ecomate.backend.specialpickup.dto;

import java.util.ArrayList;
import java.util.List;

public class CapacityCheckResponse {

    private boolean canApprove;

    private Double maxWeightKg;
    private Double currentWeightKg;
    private Double requestedWeightKg;
    private Double expectedWeightKg;
    private Double remainingWeightKg;

    private Double maxVolumeM3;
    private Double currentVolumeM3;
    private Double requestedVolumeM3;
    private Double expectedVolumeM3;
    private Double remainingVolumeM3;

    private Integer maxHouseholds;
    private Integer joinedHouseholds;
    private Integer expectedHouseholds;

    private boolean wasteTypeAccepted;
    private boolean householdCapacityAvailable;
    private boolean weightCapacityAvailable;
    private boolean volumeCapacityAvailable;

    private List<String> warnings = new ArrayList<>();

    public CapacityCheckResponse() {
    }

    public boolean isCanApprove() {
        return canApprove;
    }

    public void setCanApprove(boolean canApprove) {
        this.canApprove = canApprove;
    }

    public Double getMaxWeightKg() {
        return maxWeightKg;
    }

    public void setMaxWeightKg(Double maxWeightKg) {
        this.maxWeightKg = maxWeightKg;
    }

    public Double getCurrentWeightKg() {
        return currentWeightKg;
    }

    public void setCurrentWeightKg(Double currentWeightKg) {
        this.currentWeightKg = currentWeightKg;
    }

    public Double getRequestedWeightKg() {
        return requestedWeightKg;
    }

    public void setRequestedWeightKg(Double requestedWeightKg) {
        this.requestedWeightKg = requestedWeightKg;
    }

    public Double getExpectedWeightKg() {
        return expectedWeightKg;
    }

    public void setExpectedWeightKg(Double expectedWeightKg) {
        this.expectedWeightKg = expectedWeightKg;
    }

    public Double getRemainingWeightKg() {
        return remainingWeightKg;
    }

    public void setRemainingWeightKg(Double remainingWeightKg) {
        this.remainingWeightKg = remainingWeightKg;
    }

    public Double getMaxVolumeM3() {
        return maxVolumeM3;
    }

    public void setMaxVolumeM3(Double maxVolumeM3) {
        this.maxVolumeM3 = maxVolumeM3;
    }

    public Double getCurrentVolumeM3() {
        return currentVolumeM3;
    }

    public void setCurrentVolumeM3(Double currentVolumeM3) {
        this.currentVolumeM3 = currentVolumeM3;
    }

    public Double getRequestedVolumeM3() {
        return requestedVolumeM3;
    }

    public void setRequestedVolumeM3(Double requestedVolumeM3) {
        this.requestedVolumeM3 = requestedVolumeM3;
    }

    public Double getExpectedVolumeM3() {
        return expectedVolumeM3;
    }

    public void setExpectedVolumeM3(Double expectedVolumeM3) {
        this.expectedVolumeM3 = expectedVolumeM3;
    }

    public Double getRemainingVolumeM3() {
        return remainingVolumeM3;
    }

    public void setRemainingVolumeM3(Double remainingVolumeM3) {
        this.remainingVolumeM3 = remainingVolumeM3;
    }

    public Integer getMaxHouseholds() {
        return maxHouseholds;
    }

    public void setMaxHouseholds(Integer maxHouseholds) {
        this.maxHouseholds = maxHouseholds;
    }

    public Integer getJoinedHouseholds() {
        return joinedHouseholds;
    }

    public void setJoinedHouseholds(Integer joinedHouseholds) {
        this.joinedHouseholds = joinedHouseholds;
    }

    public Integer getExpectedHouseholds() {
        return expectedHouseholds;
    }

    public void setExpectedHouseholds(Integer expectedHouseholds) {
        this.expectedHouseholds = expectedHouseholds;
    }

    public boolean isWasteTypeAccepted() {
        return wasteTypeAccepted;
    }

    public void setWasteTypeAccepted(boolean wasteTypeAccepted) {
        this.wasteTypeAccepted = wasteTypeAccepted;
    }

    public boolean isHouseholdCapacityAvailable() {
        return householdCapacityAvailable;
    }

    public void setHouseholdCapacityAvailable(boolean householdCapacityAvailable) {
        this.householdCapacityAvailable = householdCapacityAvailable;
    }

    public boolean isWeightCapacityAvailable() {
        return weightCapacityAvailable;
    }

    public void setWeightCapacityAvailable(boolean weightCapacityAvailable) {
        this.weightCapacityAvailable = weightCapacityAvailable;
    }

    public boolean isVolumeCapacityAvailable() {
        return volumeCapacityAvailable;
    }

    public void setVolumeCapacityAvailable(boolean volumeCapacityAvailable) {
        this.volumeCapacityAvailable = volumeCapacityAvailable;
    }

    public List<String> getWarnings() {
        return warnings;
    }

    public void setWarnings(List<String> warnings) {
        this.warnings = warnings;
    }
}