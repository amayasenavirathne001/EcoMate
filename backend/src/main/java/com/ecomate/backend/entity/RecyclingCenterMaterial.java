package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "recycling_center_materials", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"recycling_center_id", "material_id"})
})
public class RecyclingCenterMaterial {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recycling_center_id", nullable = false)
    private RecyclingCenter RecyclingCenter;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "material_id", nullable = false)
    private Material material;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public RecyclingCenterMaterial() {
    }

    public RecyclingCenterMaterial(RecyclingCenter RecyclingCenter, Material material, Boolean isActive) {
        this.RecyclingCenter = RecyclingCenter;
        this.material = material;
        this.isActive = isActive;
        this.updatedAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public RecyclingCenter getRecyclingCenter() {
        return RecyclingCenter;
    }

    public void setRecyclingCenter(RecyclingCenter RecyclingCenter) {
        this.RecyclingCenter = RecyclingCenter;
    }

    public Material getMaterial() {
        return material;
    }

    public void setMaterial(Material material) {
        this.material = material;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
