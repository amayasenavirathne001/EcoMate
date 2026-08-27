package com.ecomate.backend.controller;

import com.ecomate.backend.dto.CreateWasteReportRequest;
import com.ecomate.backend.dto.WasteReportResponse;
import com.ecomate.backend.service.WasteReportService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/resident/reports")
public class WasteReportController {
    private final WasteReportService service;

    public WasteReportController(WasteReportService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public WasteReportResponse create(@AuthenticationPrincipal Jwt jwt,
                                      @Valid @RequestBody CreateWasteReportRequest request) {
        return service.create(jwt.getSubject(), request);
    }

    @GetMapping
    public List<WasteReportResponse> mine(@AuthenticationPrincipal Jwt jwt) {
        return service.findMine(jwt.getSubject());
    }

}
