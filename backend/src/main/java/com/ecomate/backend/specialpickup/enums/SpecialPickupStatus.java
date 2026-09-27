package com.ecomate.backend.specialpickup.enums;

public enum SpecialPickupStatus {

    // Admin has created the pickup from a schedule,
    // but truck/collector has not been assigned yet.
    SCHEDULED,

    // Truck/collector assigned.
    // Residents can see and join this pickup.
    ASSIGNED,

    // Household or truck capacity has been reached.
    // Residents can no longer join.
    FULL,

    // Collection has started.
    // Residents can no longer join.
    IN_PROGRESS,

    // Collection has finished.
    COMPLETED,

    // Pickup was cancelled.
    CANCELLED
}