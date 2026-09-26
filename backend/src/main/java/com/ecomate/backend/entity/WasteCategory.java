package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "waste_categories")
public class WasteCategory {

    @Id
    private String id; // e.g. plastics, paper, glass, metals, organic, e_waste, hazardous

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private boolean isRecyclable;

    @Column(length = 2000)
    private String description;

    private String binColorName;
    private String binColor; // e.g. "0xFFF59E0B"
    private String icon; // string identifier for Flutter icons

    @ElementCollection
    @CollectionTable(name = "waste_category_common_items", joinColumns = @JoinColumn(name = "waste_category_id"))
    @Column(name = "item")
    private List<String> commonItems;

    @ElementCollection
    @CollectionTable(name = "waste_category_prep_steps", joinColumns = @JoinColumn(name = "waste_category_id"))
    @Column(name = "step")
    private List<String> preparationSteps;

    @ElementCollection
    @CollectionTable(name = "waste_category_dos", joinColumns = @JoinColumn(name = "waste_category_id"))
    @Column(name = "do_item")
    private List<String> dos;

    @ElementCollection
    @CollectionTable(name = "waste_category_donts", joinColumns = @JoinColumn(name = "waste_category_id"))
    @Column(name = "dont_item")
    private List<String> donts;

    public WasteCategory() {
    }

    public WasteCategory(String id, String name, boolean isRecyclable) {
        this.id = id;
        this.name = name;
        this.isRecyclable = isRecyclable;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public boolean isRecyclable() { return isRecyclable; }
    public void setRecyclable(boolean recyclable) { isRecyclable = recyclable; }

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
