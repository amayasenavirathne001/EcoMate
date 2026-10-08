package com.ecomate.backend.specialpickup.entity;

import com.ecomate.backend.specialpickup.enums.JoinRequestStatus;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "special_pickup_join_requests")
public class SpecialPickupJoinRequest {

    // =========================================================
    // ID
    // =========================================================

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    // =========================================================
    // SPECIAL PICKUP
    // =========================================================

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "special_pickup_id", nullable = false)
    private SpecialPickup specialPickup;


    // =========================================================
    // RESIDENT
    // =========================================================

    /*
     * Stores the ID of the resident who requested to join
     * the special pickup.
     *
     * We store only the resident ID here to keep this feature
     * isolated and avoid mapping resident_id twice.
     */
    @Column(name = "resident_id", nullable = false)
    private Long residentId;


    // =========================================================
    // WASTE DETAILS
    // =========================================================

    @Column(name = "waste_type", nullable = false)
    private String wasteType;

    @Column(name = "number_of_items", nullable = false)
    private Integer numberOfItems;

    @Column(name = "estimated_size")
    private String estimatedSize;

    @Column(name = "estimated_weight_kg")
    private Double estimatedWeightKg;

    @Column(name = "estimated_volume_m3")
    private Double estimatedVolumeM3;


    // =========================================================
    // PICKUP DETAILS
    // =========================================================

    @Column(name = "pickup_address", nullable = false)
    private String pickupAddress;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "photo_url")
    private String photoUrl;


    // =========================================================
    // JOIN REQUEST STATUS
    // =========================================================

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private JoinRequestStatus status =
            JoinRequestStatus.PENDING_APPROVAL;

    /*
     * Used when an administrator rejects a join request.
     *
     * Example:
     * "Truck capacity has been reached."
     */
    @Column(name = "admin_reason", columnDefinition = "TEXT")
    private String adminReason;


    // =========================================================
    // TIMESTAMPS
    // =========================================================

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;


    // =========================================================
    // CONSTRUCTOR
    // =========================================================

    public SpecialPickupJoinRequest() {
    }


    // =========================================================
    // JPA LIFECYCLE METHODS
    // =========================================================

    @PrePersist
    protected void onCreate() {

        LocalDateTime now = LocalDateTime.now();

        if (createdAt == null) {
            createdAt = now;
        }

        if (updatedAt == null) {
            updatedAt = now;
        }

        if (status == null) {
            status = JoinRequestStatus.PENDING_APPROVAL;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }


    // =========================================================
    // GETTERS AND SETTERS
    // =========================================================

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }


    public SpecialPickup getSpecialPickup() {
        return specialPickup;
    }

    public void setSpecialPickup(SpecialPickup specialPickup) {
        this.specialPickup = specialPickup;
    }


    public Long getResidentId() {
        return residentId;
    }

    public void setResidentId(Long residentId) {
        this.residentId = residentId;
    }


    public String getWasteType() {
        return wasteType;
    }

    public void setWasteType(String wasteType) {
        this.wasteType = wasteType;
    }


    public Integer getNumberOfItems() {
        return numberOfItems;
    }

    public void setNumberOfItems(Integer numberOfItems) {
        this.numberOfItems = numberOfItems;
    }


    public String getEstimatedSize() {
        return estimatedSize;
    }

    public void setEstimatedSize(String estimatedSize) {
        this.estimatedSize = estimatedSize;
    }


    public Double getEstimatedWeightKg() {
        return estimatedWeightKg;
    }

    public void setEstimatedWeightKg(Double estimatedWeightKg) {
        this.estimatedWeightKg = estimatedWeightKg;
    }


    public Double getEstimatedVolumeM3() {
        return estimatedVolumeM3;
    }

    public void setEstimatedVolumeM3(Double estimatedVolumeM3) {
        this.estimatedVolumeM3 = estimatedVolumeM3;
    }


    public String getPickupAddress() {
        return pickupAddress;
    }

    public void setPickupAddress(String pickupAddress) {
        this.pickupAddress = pickupAddress;
    }


    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }


    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }


    public JoinRequestStatus getStatus() {
        return status;
    }

    public void setStatus(JoinRequestStatus status) {
        this.status = status;
    }


    public String getAdminReason() {
        return adminReason;
    }

    public void setAdminReason(String adminReason) {
        this.adminReason = adminReason;
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


    public LocalDateTime getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(LocalDateTime approvedAt) {
        this.approvedAt = approvedAt;
    }
}