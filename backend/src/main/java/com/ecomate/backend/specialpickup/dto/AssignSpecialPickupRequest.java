package com.ecomate.backend.specialpickup.dto;

public class AssignSpecialPickupRequest {

    private Long truckId;

    public AssignSpecialPickupRequest() {
    }

    public Long getTruckId() {
        return truckId;
    }

    public void setTruckId(Long truckId) {
        this.truckId = truckId;
    }
}