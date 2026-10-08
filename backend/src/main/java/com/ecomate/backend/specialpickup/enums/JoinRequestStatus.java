package com.ecomate.backend.specialpickup.enums;

public enum JoinRequestStatus {

    // Kept for compatibility / optional manual review.
    PENDING_APPROVAL,

    // Resident passed automatic capacity checks
    // and successfully joined the shared pickup.
    APPROVED,

    // The resident's collection has been assigned
    // to a truck / collector.
    ASSIGNED,

    // Waste has actually been collected.
    COMPLETED,

    // Resident could not join the pickup.
    REJECTED
}