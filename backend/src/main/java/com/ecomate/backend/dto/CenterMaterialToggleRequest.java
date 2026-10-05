package com.ecomate.backend.dto;

public class CenterMaterialToggleRequest {
    private Long materialId;
    private Boolean isActive;

    public CenterMaterialToggleRequest() {
    }

    public CenterMaterialToggleRequest(Long materialId, Boolean isActive) {
        this.materialId = materialId;
        this.isActive = isActive;
    }

    public Long getMaterialId() {
        return materialId;
    }

    public void setMaterialId(Long materialId) {
        this.materialId = materialId;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
