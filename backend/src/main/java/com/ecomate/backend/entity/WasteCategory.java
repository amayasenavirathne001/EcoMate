package com.ecomate.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "waste_categories")
public class WasteCategory {

    @Id
    private String id; // e.g. plastics, paper, glass, metals, organic, e_waste, hazardous

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private boolean isRecyclable;

    public WasteCategory() {
    }

    public WasteCategory(String id, String name, boolean isRecyclable) {
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
