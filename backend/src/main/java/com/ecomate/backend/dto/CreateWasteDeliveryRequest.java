package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public class CreateWasteDeliveryRequest {

    private Long recyclingCentreId;

    @NotBlank(message = "Material type is required")
    private String materialType;

    @NotNull(message = "Weight is required")
    @Positive(message = "Weight must be greater than zero")
    private Double weightKg;

    @NotBlank(message = "Delivered by name is required")
    private String deliveredBy;

    private String contactNumber;
    private String notes;

    public CreateWasteDeliveryRequest() {
    }

    public Long getRecyclingCentreId() {
        return recyclingCentreId;
    }

    public void setRecyclingCentreId(Long recyclingCentreId) {
        this.recyclingCentreId = recyclingCentreId;
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

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
