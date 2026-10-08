package com.ecomate.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @NotBlank @Size(max = 80) String name,
        @Size(max = 32) @Pattern(regexp = "^(?:|[+0-9() .-]{7,32})$", message = "Enter a valid phone number") String phoneNumber,
        @Size(max = 240) String address,
        @Size(max = 1_500_000) String profilePictureData
) {
}