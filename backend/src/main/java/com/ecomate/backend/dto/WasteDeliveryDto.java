package com.ecomate.backend.dto;

import com.ecomate.backend.entity.WasteDelivery;
import java.time.format.DateTimeFormatter;

public class WasteDeliveryDto {

    private Long id;
    private Long recyclingCentreId;
    private String recyclingCentreName;
    private String materialType;
    private Double weightKg;
    private String deliveredBy;
    private String contactNumber;
    private String dateTime;
    private String notes;

    public WasteDeliveryDto() {
    }

    public static WasteDeliveryDto fromEntity(WasteDelivery entity) {
        WasteDeliveryDto dto = new WasteDeliveryDto();
        dto.setId(entity.getId());
        if (entity.getRecyclingCentre() != null) {
            dto.setRecyclingCentreId(entity.getRecyclingCentre().getId());
            dto.setRecyclingCentreName(entity.getRecyclingCentre().getName());
        }
        dto.setMaterialType(entity.getMaterialType());
        dto.setWeightKg(entity.getWeightKg());
        dto.setDeliveredBy(entity.getDeliveredBy());
        dto.setContactNumber(entity.getContactNumber());
        if (entity.getDateTime() != null) {
            dto.setDateTime(entity.getDateTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        }
        dto.setNotes(entity.getNotes());
        return dto;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getRecyclingCentreId() {
        return recyclingCentreId;
    }

    public void setRecyclingCentreId(Long recyclingCentreId) {
        this.recyclingCentreId = recyclingCentreId;
    }

    public String getRecyclingCentreName() {
        return recyclingCentreName;
    }

    public void setRecyclingCentreName(String recyclingCentreName) {
        this.recyclingCentreName = recyclingCentreName;
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

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
