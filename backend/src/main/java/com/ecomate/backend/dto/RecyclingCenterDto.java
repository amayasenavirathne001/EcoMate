package com.ecomate.backend.dto;

import java.util.List;

public class RecyclingCenterDto {
    private String id;
    private String name;
    private String address;
    private String city;
    private Double distanceKm;
    private String contactNumber;
    private String email;
    private String operatingHours;
    private boolean isOpen;
    private List<String> acceptedMaterials;
    private String notes;

    public RecyclingCenterDto() {
    }

    public RecyclingCenterDto(String id, String name, String address, String city, Double distanceKm, String contactNumber, String email, String operatingHours, boolean isOpen, List<String> acceptedMaterials, String notes) {
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
