package com.ecomate.backend.specialpickup.controller;

import com.ecomate.backend.specialpickup.dto.CapacityCheckResponse;
import com.ecomate.backend.specialpickup.dto.CreateJoinRequest;
import com.ecomate.backend.specialpickup.dto.JoinRequestResponse;
import com.ecomate.backend.specialpickup.dto.SpecialPickupResponse;
import com.ecomate.backend.specialpickup.service.SpecialPickupJoinService;
import com.ecomate.backend.specialpickup.service.SpecialPickupService;
import com.ecomate.backend.specialpickup.dto.CreateSpecialPickupRequest;
import com.ecomate.backend.specialpickup.entity.SpecialPickup;
import com.ecomate.backend.specialpickup.dto.AssignSpecialPickupRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class SpecialPickupController {

    private final SpecialPickupService specialPickupService;
    private final SpecialPickupJoinService joinService;

    public SpecialPickupController(
            SpecialPickupService specialPickupService,
            SpecialPickupJoinService joinService) {

        this.specialPickupService = specialPickupService;
        this.joinService = joinService;
    }
        // =========================================================
        // ADMIN - CREATE SPECIAL PICKUP FROM SCHEDULE
        // =========================================================

        @PostMapping("/admin/special-pickups")
        public ResponseEntity<SpecialPickup> createSpecialPickup(
                @RequestBody CreateSpecialPickupRequest request,
                @RequestParam(defaultValue = "1") Long adminId) {

        SpecialPickup pickup =
                specialPickupService.createPickupFromSchedule(
                        request,
                        adminId);

        return ResponseEntity.ok(pickup);
        }
        // =========================================================
        // ADMIN - GET ALL SPECIAL PICKUPS
        // =========================================================

        @GetMapping("/admin/special-pickups")
        public ResponseEntity<List<SpecialPickup>>
        getAllSpecialPickups() {

        List<SpecialPickup> pickups =
                specialPickupService.getAllSpecialPickups();

        return ResponseEntity.ok(pickups);
        }
        // =========================================================
        // ADMIN - ASSIGN TRUCK TO SPECIAL PICKUP
        // =========================================================

        @PutMapping("/admin/special-pickups/{pickupId}/assign")
        public ResponseEntity<SpecialPickup> assignSpecialPickup(
                @PathVariable Long pickupId,
                @RequestBody AssignSpecialPickupRequest request) {

        SpecialPickup pickup =
                specialPickupService.assignPickup(
                        pickupId,
                        request.getTruckId());

        return ResponseEntity.ok(pickup);
        }
    // =========================================================
    // RESIDENT - GET AVAILABLE SPECIAL PICKUPS
    // =========================================================

    @GetMapping("/special-pickups")
    public ResponseEntity<List<SpecialPickupResponse>>
    getSpecialPickups(Authentication authentication) {

        String residentEmail = authentication.getName();

        List<SpecialPickupResponse> pickups =
                specialPickupService.getAvailablePickups(
                        residentEmail);

        return ResponseEntity.ok(pickups);
    }

    // =========================================================
    // RESIDENT - GET ONE SPECIAL PICKUP
    // =========================================================

    @GetMapping("/special-pickups/{pickupId}")
    public ResponseEntity<SpecialPickupResponse>
    getSpecialPickup(
            @PathVariable Long pickupId,
            Authentication authentication) {

        String residentEmail = authentication.getName();

        SpecialPickupResponse pickup =
                specialPickupService.getPickup(
                        pickupId,
                        residentEmail);

        return ResponseEntity.ok(pickup);
    }

    // =========================================================
    // RESIDENT - REQUEST TO JOIN SPECIAL PICKUP
    // =========================================================

    @PostMapping("/special-pickups/{pickupId}/join")
    public ResponseEntity<JoinRequestResponse>
    joinSpecialPickup(
            @PathVariable Long pickupId,
            @RequestBody CreateJoinRequest request,
            Authentication authentication) {

        String residentEmail = authentication.getName();

        JoinRequestResponse response =
                joinService.createJoinRequest(
                        pickupId,
                        residentEmail,
                        request);

        return ResponseEntity.ok(response);
    }

    // =========================================================
    // RESIDENT - GET MY JOIN REQUESTS
    // =========================================================

    @GetMapping("/special-pickup-join-requests/me")
    public ResponseEntity<List<JoinRequestResponse>>
    getMyJoinRequests(Authentication authentication) {

        String residentEmail = authentication.getName();

        List<JoinRequestResponse> requests =
                joinService.getResidentJoinRequests(
                        residentEmail);

        return ResponseEntity.ok(requests);
    }

    // =========================================================
    // ADMIN - GET ALL PENDING JOIN REQUESTS
    // =========================================================

    @GetMapping(
            "/admin/special-pickups/join-requests/pending")
    public ResponseEntity<List<JoinRequestResponse>>
    getPendingJoinRequests() {

        List<JoinRequestResponse> requests =
                joinService.getPendingJoinRequests();

        return ResponseEntity.ok(requests);
    }

    // =========================================================
    // ADMIN - CHECK TRUCK / PICKUP CAPACITY
    // =========================================================

    @GetMapping(
            "/admin/special-pickups/join-requests/{joinRequestId}/capacity")
    public ResponseEntity<CapacityCheckResponse>
    checkCapacity(
            @PathVariable Long joinRequestId) {

        CapacityCheckResponse response =
                joinService.checkCapacity(
                        joinRequestId);

        return ResponseEntity.ok(response);
    }

    // =========================================================
    // ADMIN - APPROVE JOIN REQUEST
    // =========================================================

    @PostMapping(
            "/admin/special-pickups/join-requests/{joinRequestId}/approve")
    public ResponseEntity<JoinRequestResponse>
    approveJoinRequest(
            @PathVariable Long joinRequestId) {

        JoinRequestResponse response =
                joinService.approveJoinRequest(
                        joinRequestId);

        return ResponseEntity.ok(response);
    }

    // =========================================================
    // ADMIN - REJECT JOIN REQUEST
    // =========================================================

    @PostMapping(
            "/admin/special-pickups/join-requests/{joinRequestId}/reject")
    public ResponseEntity<JoinRequestResponse>
    rejectJoinRequest(
            @PathVariable Long joinRequestId,
            @RequestBody(required = false)
            Map<String, String> body) {

        String reason = null;

        if (body != null) {
            reason = body.get("reason");
        }

        JoinRequestResponse response =
                joinService.rejectJoinRequest(
                        joinRequestId,
                        reason);

        return ResponseEntity.ok(response);
    }
}