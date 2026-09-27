package com.ecomate.backend.specialpickup.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CreateJoinRequest {

    @NotBlank(message = "Waste type is required")
    private String wasteType;

    @NotNull(message = "Number of items is required")
    @Min(value = 1, message = "Number of items must be at least 1")
    private Integer numberOfItems;

    @NotBlank(message = "Estimated size is required")
    private String estimatedSize;

    private Double estimatedWeightKg;
    private Double estimatedVolumeM3;

    @NotBlank(message = "Pickup address is required")
    private String pickupAddress;

    private String notes;
    private String photoUrl;

    public CreateJoinRequest() {}

    public String getWasteType() { return wasteType; }
    public void setWasteType(String wasteType) { this.wasteType = wasteType; }

    public Integer getNumberOfItems() { return numberOfItems; }
    public void setNumberOfItems(Integer numberOfItems) { this.numberOfItems = numberOfItems; }

    public String getEstimatedSize() { return estimatedSize; }
    public void setEstimatedSize(String estimatedSize) { this.estimatedSize = estimatedSize; }

    public Double getEstimatedWeightKg() { return estimatedWeightKg; }
    public void setEstimatedWeightKg(Double estimatedWeightKg) { this.estimatedWeightKg = estimatedWeightKg; }

    public Double getEstimatedVolumeM3() { return estimatedVolumeM3; }
    public void setEstimatedVolumeM3(Double estimatedVolumeM3) { this.estimatedVolumeM3 = estimatedVolumeM3; }

    public String getPickupAddress() { return pickupAddress; }
    public void setPickupAddress(String pickupAddress) { this.pickupAddress = pickupAddress; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
}
