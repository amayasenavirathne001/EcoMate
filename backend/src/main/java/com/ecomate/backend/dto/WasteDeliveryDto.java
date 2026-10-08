package com.ecomate.backend.dto;

import com.ecomate.backend.entity.WasteDelivery;
import java.time.format.DateTimeFormatter;

public class WasteDeliveryDto {

    private Long id;
    private Long recyclingcenterId;
    private String RecyclingCenterName;
    private String materialType;
    private Double weightKg;
    private String deliveredBy;
    private String contactNumber;
    private String dateTime;
    private String notes;
    private String processingStatus;

    public WasteDeliveryDto() {
    }

    public static WasteDeliveryDto fromEntity(WasteDelivery entity) {
        WasteDeliveryDto dto = new WasteDeliveryDto();
        dto.setId(entity.getId());
        if (entity.getRecyclingCenter() != null) {
            dto.setRecyclingcenterId(entity.getRecyclingCenter().getId());
            dto.setRecyclingCenterName(entity.getRecyclingCenter().getName());
        }
        dto.setMaterialType(entity.getMaterialType());
        dto.setWeightKg(entity.getWeightKg());
        dto.setDeliveredBy(entity.getDeliveredBy());
        dto.setContactNumber(entity.getContactNumber());
        if (entity.getDateTime() != null) {
            dto.setDateTime(entity.getDateTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        }
        dto.setNotes(entity.getNotes());
        dto.setProcessingStatus(entity.getProcessingStatus());
        return dto;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getRecyclingcenterId() {
        return recyclingcenterId;
    }

    public void setRecyclingcenterId(Long recyclingcenterId) {
        this.recyclingcenterId = recyclingcenterId;
    }

    public String getRecyclingCenterName() {
        return RecyclingCenterName;
    }

    public void setRecyclingCenterName(String RecyclingCenterName) {
        this.RecyclingCenterName = RecyclingCenterName;
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

    public String getProcessingStatus() { return processingStatus; }
    public void setProcessingStatus(String processingStatus) { this.processingStatus = processingStatus; }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}



