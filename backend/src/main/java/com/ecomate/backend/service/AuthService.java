package com.ecomate.backend.service;

import com.ecomate.backend.dto.AuthResponse;
import com.ecomate.backend.dto.LoginRequest;
import com.ecomate.backend.dto.RegisterRequest;
import com.ecomate.backend.dto.UpdateProfileRequest;
import com.ecomate.backend.entity.User;
import com.ecomate.backend.repository.UserRepository;
import com.ecomate.backend.security.JwtService;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {

        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public User register(RegisterRequest request) {

        if (userRepository.existsByEmail(request.email())) {
            throw new RuntimeException("Email already registered");
        }

        User user = new User();

        user.setName(request.name());
        user.setEmail(request.email());

        user.setPassword(
                passwordEncoder.encode(request.password())
        );

        user.setRole(request.role());

        return userRepository.save(user);
    }

    public AuthResponse login(LoginRequest request) {

        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() ->
                        new RuntimeException(
                                "Invalid email or password"
                        ));

        if (!passwordEncoder.matches(
                request.password(),
                user.getPassword())) {

            throw new RuntimeException(
                    "Invalid email or password"
            );
        }

        String token = jwtService.generateToken(user);

        return new AuthResponse(
                token,
                user.getRole().name(),
                user.getName(),
                user.getEmail()
        );
    }

    public User getUserByEmail(String email) {

        return userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RuntimeException("User not found"));
    }

    public User updateProfile(String email, UpdateProfileRequest request) {
        User user = getUserByEmail(email);
        user.updateProfile(
                request.name().trim(),
                request.phoneNumber() == null ? "" : request.phoneNumber().trim(),
                request.address() == null ? "" : request.address().trim(),
                request.profilePictureData() == null ? "" : request.profilePictureData());
        return userRepository.save(user);
    }
}