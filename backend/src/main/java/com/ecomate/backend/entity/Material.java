package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "materials")
public class Material {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false)
    private String category;

    @Column(length = 1000)
    private String description = "";

    @Column(name = "image_url", length = 1000)
    private String imageUrl = "";

    @Column(name = "bin_color")
    private String binColor = "#2E7D32";

    @Column(name = "is_recyclable", nullable = false)
    private Boolean isRecyclable = true;

    @Column(name = "preparation_tips", length = 1000)
    private String preparationTips = "";

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Material() {
    }

    public Material(String name, String category, String description, String imageUrl,
                    String binColor, Boolean isRecyclable, String preparationTips) {
        this.name = name;
        this.category = category;
        this.description = description;
        this.imageUrl = imageUrl;
        this.binColor = binColor;
        this.isRecyclable = isRecyclable;
        this.preparationTips = preparationTips;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}