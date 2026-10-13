
package com.ecomate.backend.specialpickup.dto;

public class AssignSpecialPickupRequest {

    private Long truckId;
    private Long driverId;

    public AssignSpecialPickupRequest() {
    }

    public Long getTruckId() {
        return truckId;
    }

    public void setTruckId(Long truckId) {
        this.truckId = truckId;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }
}
