package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.List;

public class RecyclingCentreRequest {

    @NotBlank(message = "Centre name is required")
    private String name;

    @NotBlank(message = "Address is required")
    private String address;

    @NotBlank(message = "City is required")
    private String city;

    @NotBlank(message = "Contact phone is required")
    private String contactNumber;

    @NotBlank(message = "Email is required")
    private String email;

    private String operatingHours;
    private Boolean isOpen;
    private List<String> acceptedMaterials;
    private List<String> unsupportedMaterials;
    private String notes;

    public RecyclingCentreRequest() {
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

    public List<String> getAcceptedMaterials() {
        return acceptedMaterials;
    }

    public void setAcceptedMaterials(List<String> acceptedMaterials) {
        this.acceptedMaterials = acceptedMaterials;
    }

    public List<String> getUnsupportedMaterials() {
        return unsupportedMaterials;
    }

    public void setUnsupportedMaterials(List<String> unsupportedMaterials) {
        this.unsupportedMaterials = unsupportedMaterials;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}