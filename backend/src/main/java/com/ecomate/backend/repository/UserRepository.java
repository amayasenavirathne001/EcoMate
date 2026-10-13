//It lets Spring Boot communicate with your users table without you 
// manually writing SQL for basic operations
package com.ecomate.backend.repository;

import com.ecomate.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    java.util.List<User> findByRole(com.ecomate.backend.entity.Role role);
}