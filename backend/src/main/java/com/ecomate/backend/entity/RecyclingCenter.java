package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recycling_centers")
public class RecyclingCenter {

    @Id
    private String id; // rc_01, rc_02, etc.

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private String city;

    private Double distanceKm;

    private String contactNumber;

    private String email;

    private String operatingHours;

    private boolean isOpen = true;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "recycling_center_materials", joinColumns = @JoinColumn(name = "recycling_center_id"))
    @Column(name = "material")
    private List<String> acceptedMaterials = new ArrayList<>();

    @Column(columnDefinition = "TEXT")
    private String notes;

    public RecyclingCenter() {
    }

    public RecyclingCenter(String id, String name, String address, String city, Double distanceKm, String contactNumber, String email, String operatingHours, boolean isOpen, List<String> acceptedMaterials, String notes) {
        this.id = id;
        this.name = name;
        this.address = address;
        this.city = city;
        this.distanceKm = distanceKm;
        this.contactNumber = contactNumber;
        this.email = email;
        this.operatingHours = operatingHours;
        this.isOpen = isOpen;
        this.acceptedMaterials = acceptedMaterials;
        this.notes = notes;
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

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Double getDistanceKm() {
        return distanceKm;
    }

    public void setDistanceKm(Double distanceKm) {
        this.distanceKm = distanceKm;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getOperatingHours() {
        return operatingHours;
    }

    public void setOperatingHours(String operatingHours) {
        this.operatingHours = operatingHours;
    }

    public boolean isOpen() {
        return isOpen;
    }

    public void setOpen(boolean open) {
        isOpen = open;
    }

    public List<String> getAcceptedMaterials() {
        return acceptedMaterials;
    }

    public void setAcceptedMaterials(List<String> acceptedMaterials) {
        this.acceptedMaterials = acceptedMaterials;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
