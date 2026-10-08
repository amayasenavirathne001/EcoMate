package com.ecomate.backend.repository;

import com.ecomate.backend.entity.EcoWallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EcoWalletRepository extends JpaRepository<EcoWallet, Long> {
    Optional<EcoWallet> findByUserEmail(String userEmail);
}
