package com.ecomate.backend.controller;

import com.ecomate.backend.dto.UpdateWasteReportRequest;
import com.ecomate.backend.dto.WasteReportResponse;
import com.ecomate.backend.service.WasteReportService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/municipal/reports")
public class MunicipalReportController {
    private final WasteReportService service;

    public MunicipalReportController(WasteReportService service) {
        this.service = service;
    }

    @GetMapping
    public List<WasteReportResponse> all() {
        return service.findAll();
    }

    @PutMapping("/{id}")
    public WasteReportResponse update(@PathVariable Long id,
                                      @Valid @RequestBody UpdateWasteReportRequest request) {
        return service.update(id, request);
    }
}