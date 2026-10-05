package com.ecomate.backend.controller;

import com.ecomate.backend.dto.CreateWasteDeliveryRequest;
import com.ecomate.backend.dto.WasteDeliveryDto;
import com.ecomate.backend.service.WasteDeliveryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recycling/deliveries")
public class WasteDeliveryController {

    private final WasteDeliveryService wasteDeliveryService;

    public WasteDeliveryController(WasteDeliveryService wasteDeliveryService) {
        this.wasteDeliveryService = wasteDeliveryService;
    }

    @PostMapping
    public ResponseEntity<WasteDeliveryDto> recordDelivery(
            Authentication authentication,
            @Valid @RequestBody CreateWasteDeliveryRequest request) {
        String email = authentication != null ? authentication.getName() : null;
        WasteDeliveryDto saved = wasteDeliveryService.recordDelivery(email, request);
        return ResponseEntity.ok(saved);
    }

    @GetMapping
    public ResponseEntity<List<WasteDeliveryDto>> getDeliveries(
            Authentication authentication,
            @RequestParam(required = false) Long CenterId) {
        if (CenterId != null) {
            return ResponseEntity.ok(wasteDeliveryService.getDeliveriesForCenter(CenterId));
        }
        String email = authentication != null ? authentication.getName() : "";
        return ResponseEntity.ok(wasteDeliveryService.getDeliveriesForUser(email));
    }

    @GetMapping("/Center/{CenterId}")
    public ResponseEntity<List<WasteDeliveryDto>> getDeliveriesByCenter(@PathVariable Long CenterId) {
        return ResponseEntity.ok(wasteDeliveryService.getDeliveriesForCenter(CenterId));
    }
    @PatchMapping("/{id}/status")
    public ResponseEntity<Void> updateProcessingStatus(
            @PathVariable Long id,
            @RequestBody java.util.Map<String, String> payload) {
        String newStatus = payload.get("processingStatus");
        if (newStatus != null) {
            wasteDeliveryService.updateProcessingStatus(id, newStatus);
        }
        return ResponseEntity.ok().build();
    }
}

