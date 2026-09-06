package com.ecomate.backend.dto;

import com.ecomate.backend.entity.Material;

public class MaterialDto {
    private Long id;
    private String name;
    private String category;
    private String description;
    private String imageUrl;
    private String binColor;
    private Boolean isRecyclable;
    private String preparationTips;
    private Boolean isActive = true; // 1 or 0 for centre context

    public MaterialDto() {
    }

    public static MaterialDto fromEntity(Material m) {
        MaterialDto dto = new MaterialDto();
        dto.setId(m.getId());
        dto.setName(m.getName());
        dto.setCategory(m.getCategory());
        dto.setDescription(m.getDescription());
        dto.setImageUrl(m.getImageUrl());
        dto.setBinColor(m.getBinColor());
        dto.setIsRecyclable(m.getIsRecyclable());
        dto.setPreparationTips(m.getPreparationTips());
        return dto;
    }

    public static MaterialDto fromEntityWithStatus(Material m, Boolean isActive) {
        MaterialDto dto = fromEntity(m);
        dto.setIsActive(isActive);
        return dto;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getBinColor() {
        return binColor;
    }

    public void setBinColor(String binColor) {
        this.binColor = binColor;
    }

    public Boolean getIsRecyclable() {
        return isRecyclable;
    }

    public void setIsRecyclable(Boolean isRecyclable) {
        this.isRecyclable = isRecyclable;
    }

    public String getPreparationTips() {
        return preparationTips;
    }

    public void setPreparationTips(String preparationTips) {
        this.preparationTips = preparationTips;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}