package com.ecomate.backend.dto;

public class WasteCategoryDto {
    private String id;
    private String name;
    private boolean isRecyclable;

    public WasteCategoryDto() {
    }

    public WasteCategoryDto(String id, String name, boolean isRecyclable) {
        this.id = id;
        this.name = name;
        this.isRecyclable = isRecyclable;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isRecyclable() {
        return isRecyclable;
    }

    public void setRecyclable(boolean recyclable) {
        isRecyclable = recyclable;
    }
}
