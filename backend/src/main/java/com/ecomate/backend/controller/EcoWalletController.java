package com.ecomate.backend.controller;

import com.ecomate.backend.dto.EcoWalletDto;
import com.ecomate.backend.service.EcoWalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/eco-points")
public class EcoWalletController {

    @Autowired
    private EcoWalletService ecoWalletService;

    @GetMapping("/my-wallet")
    public ResponseEntity<EcoWalletDto> getMyWallet() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        
        return ResponseEntity.ok(ecoWalletService.getWalletForUser(email));
    }
}
