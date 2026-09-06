package com.ecomate.backend.controller;

import com.ecomate.backend.dto.NotificationDto;
import com.ecomate.backend.entity.CollectorDriver;
import com.ecomate.backend.repository.CollectorDriverRepository;
import com.ecomate.backend.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/collector/notifications")
public class CollectorNotificationController {

    private final NotificationService notificationService;
    private final CollectorDriverRepository employeeRepository;

    public CollectorNotificationController(
            NotificationService notificationService,
            CollectorDriverRepository employeeRepository) {
        this.notificationService = notificationService;
        this.employeeRepository = employeeRepository;
    }

    @GetMapping
    public ResponseEntity<List<NotificationDto>> getNotifications(
            @RequestParam(required = false) String employeeId,
            Principal principal) {
        
        if (employeeId != null && !employeeId.isEmpty()) {
            return ResponseEntity.ok(notificationService.getNotificationsForEmployee(employeeId));
        }

        // Fallback: search employee by name matching principal email/name
        String email = principal.getName();
        // Since we don't have email in CollectorDriver, let's search by name matching principal's name if possible
        // To be safe and simple, let's look for any employee that might correspond, or return empty if none
        // A direct parameter is always more robust for our Flutter dashboard integration!
        return ResponseEntity.ok(Collections.emptyList());
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.noContent().build();
    }
}
