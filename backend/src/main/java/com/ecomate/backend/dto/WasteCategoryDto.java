package com.ecomate.backend.dto;

import java.util.List;

public class WasteCategoryDto {
    private String id;
    private String name;
    private Boolean isRecyclable;
    private String description;
    private String binColorName;
    private String binColor;
    private String icon;
    private List<String> commonItems;
    private List<String> preparationSteps;
    private List<String> dos;
    private List<String> donts;

    public WasteCategoryDto() {
    }

    public WasteCategoryDto(String id, String name, boolean isRecyclable) {
        this.id = id;
        this.name = name;
        this.isRecyclable = isRecyclable;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    @com.fasterxml.jackson.annotation.JsonProperty("isRecyclable")
    @com.fasterxml.jackson.annotation.JsonAlias("recyclable")
    public Boolean isRecyclable() { return isRecyclable; }
    @com.fasterxml.jackson.annotation.JsonProperty("isRecyclable")
    @com.fasterxml.jackson.annotation.JsonAlias("recyclable")
    public void setRecyclable(Boolean recyclable) { isRecyclable = recyclable; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getBinColorName() { return binColorName; }
    public void setBinColorName(String binColorName) { this.binColorName = binColorName; }

    public String getBinColor() { return binColor; }
    public void setBinColor(String binColor) { this.binColor = binColor; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public List<String> getCommonItems() { return commonItems; }
    public void setCommonItems(List<String> commonItems) { this.commonItems = commonItems; }

    public List<String> getPreparationSteps() { return preparationSteps; }
    public void setPreparationSteps(List<String> preparationSteps) { this.preparationSteps = preparationSteps; }

    public List<String> getDos() { return dos; }
    public void setDos(List<String> dos) { this.dos = dos; }

    public List<String> getDonts() { return donts; }
    public void setDonts(List<String> donts) { this.donts = donts; }
}




