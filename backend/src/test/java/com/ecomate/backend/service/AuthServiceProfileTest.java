package com.ecomate.backend.service;

import com.ecomate.backend.dto.UpdateProfileRequest;
import com.ecomate.backend.entity.Role;
import com.ecomate.backend.entity.User;
import com.ecomate.backend.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AuthServiceProfileTest {
    @Autowired
    private AuthService authService;

    @Autowired
    private UserRepository userRepository;

    @Test
    void updateProfilePersistsResidentDetailsWithoutChangingAccountIdentity() {
        String email = "resident-" + UUID.randomUUID() + "@example.com";
        User resident = userRepository.save(new User("Old Name", email, "encoded-password", Role.RESIDENT));

        User updated = authService.updateProfile(email, new UpdateProfileRequest(
                "Ayesha Perera",
                "+94 77 123 4567",
                "18 Lake Road, Colombo",
                "data:image/jpeg;base64,ZmFrZQ=="));

        User persisted = userRepository.findById(resident.getId()).orElseThrow();
        assertEquals("Ayesha Perera", updated.getName());
        assertEquals("+94 77 123 4567", persisted.getPhoneNumber());
        assertEquals("18 Lake Road, Colombo", persisted.getAddress());
        assertEquals("data:image/jpeg;base64,ZmFrZQ==", persisted.getProfilePictureData());
        assertEquals(email, persisted.getEmail());
        assertEquals("encoded-password", persisted.getPassword());
        assertEquals(Role.RESIDENT, persisted.getRole());
    }
}