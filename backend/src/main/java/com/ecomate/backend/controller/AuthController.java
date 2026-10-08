package com.ecomate.backend.controller;

import com.ecomate.backend.dto.AuthResponse;
import com.ecomate.backend.dto.LoginRequest;
import com.ecomate.backend.dto.RegisterRequest;
import com.ecomate.backend.dto.UpdateProfileRequest;
import com.ecomate.backend.dto.UserResponse;
import com.ecomate.backend.entity.User;
import com.ecomate.backend.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(
            @RequestBody RegisterRequest request) {
        User user = authService.register(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(toResponse(user));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(
            @AuthenticationPrincipal Jwt jwt) {
        User user = authService.getUserByEmail(jwt.getSubject());
        return ResponseEntity.ok(toResponse(user));
    }

    @PutMapping("/profile")
    public ResponseEntity<UserResponse> updateProfile(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody UpdateProfileRequest request) {
        User user = authService.updateProfile(jwt.getSubject(), request);
        return ResponseEntity.ok(toResponse(user));
    }

    private UserResponse toResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole(),
                user.getPhoneNumber(),
                user.getAddress(),
                user.getProfilePictureData());
    }
}