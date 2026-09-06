package com.ecomate.backend.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recycling_centres")
public class RecyclingCentre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "officer_id")
    private User officer;

    @Column(name = "officer_email", nullable = false)
    private String officerEmail;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private String city;

    @Column(name = "latitude")
    private Double latitude = 6.9271;

    @Column(name = "longitude")
    private Double longitude = 79.8612;

    @Column(name = "distance_km")
    private Double distanceKm = 1.2;

    @Column(name = "contact_number", nullable = false)
    private String contactNumber;

    @Column(nullable = false)
    private String email;

    @Column(name = "operating_hours", nullable = false)
    private String operatingHours = "Mon - Sat: 8:00 AM - 5:30 PM";

    @Column(name = "is_open", nullable = false)
    private Boolean isOpen = true;

    @Column(length = 1000)
    private String notes = "";

    @OneToMany(mappedBy = "recyclingCentre", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecyclingCentreMaterial> centreMaterials = new ArrayList<>();

    public RecyclingCentre() {
    }

    public RecyclingCentre(User officer, String officerEmail, String name, String address, String city,
                           String contactNumber, String email, String operatingHours, Boolean isOpen, String notes) {
        this.officer = officer;
        this.officerEmail = officerEmail;
        this.name = name;
        this.address = address;
        this.city = city;
        this.contactNumber = contactNumber;
        this.email = email;
        this.operatingHours = operatingHours;
        this.isOpen = isOpen;
        this.notes = notes;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getOfficer() {
        return officer;
    }

    public void setOfficer(User officer) {
        this.officer = officer;
    }

    public String getOfficerEmail() {
        return officerEmail;
    }

    public void setOfficerEmail(String officerEmail) {
        this.officerEmail = officerEmail;
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

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
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

    public Boolean getIsOpen() {
        return isOpen;
    }

    public void setIsOpen(Boolean isOpen) {
        this.isOpen = isOpen;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public List<RecyclingCentreMaterial> getCentreMaterials() {
        return centreMaterials;
    }

    public void setCentreMaterials(List<RecyclingCentreMaterial> centreMaterials) {
        this.centreMaterials = centreMaterials;
    }
}