package com.ecomate.backend.dto;

import com.ecomate.backend.entity.RecyclingCentre;
import java.util.ArrayList;
import java.util.List;

public class RecyclingCentreResponse {

    private Long id;
    private Long officerId;
    private String officerEmail;
    private String name;
    private String address;
    private String city;
    private Double latitude;
    private Double longitude;
    private Double distanceKm;
    private String contactNumber;
    private String email;
    private String operatingHours;
    private Boolean isOpen;
    private String notes;
    private List<String> acceptedMaterials = new ArrayList<>();
    private List<String> unsupportedMaterials = new ArrayList<>();
    private List<MaterialDto> materials = new ArrayList<>();

    public RecyclingCentreResponse() {
    }

    public static RecyclingCentreResponse fromEntity(RecyclingCentre entity) {
        RecyclingCentreResponse response = new RecyclingCentreResponse();
        response.setId(entity.getId());
        if (entity.getOfficer() != null) {
            response.setOfficerId(entity.getOfficer().getId());
        }
        response.setOfficerEmail(entity.getOfficerEmail());
        response.setName(entity.getName());
        response.setAddress(entity.getAddress());
        response.setCity(entity.getCity());
        response.setLatitude(entity.getLatitude());
        response.setLongitude(entity.getLongitude());
        response.setDistanceKm(entity.getDistanceKm());
        response.setContactNumber(entity.getContactNumber());
        response.setEmail(entity.getEmail());
        response.setOperatingHours(entity.getOperatingHours());
        response.setIsOpen(entity.getIsOpen());
        response.setNotes(entity.getNotes());

        if (entity.getCentreMaterials() != null) {
            entity.getCentreMaterials().forEach(cm -> {
                MaterialDto mdto = MaterialDto.fromEntityWithStatus(cm.getMaterial(), cm.getIsActive());
                response.getMaterials().add(mdto);
                if (Boolean.TRUE.equals(cm.getIsActive())) {
                    response.getAcceptedMaterials().add(cm.getMaterial().getName());
                } else {
                    response.getUnsupportedMaterials().add(cm.getMaterial().getName());
                }
            });
        }
        return response;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOfficerId() {
        return officerId;
    }

    public void setOfficerId(Long officerId) {
        this.officerId = officerId;
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

    public List<MaterialDto> getMaterials() {
        return materials;
    }

    public void setMaterials(List<MaterialDto> materials) {
        this.materials = materials;
    }
}