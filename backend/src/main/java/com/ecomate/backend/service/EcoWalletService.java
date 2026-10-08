package com.ecomate.backend.service;

import com.ecomate.backend.dto.EcoWalletDto;
import com.ecomate.backend.entity.EcoWallet;
import com.ecomate.backend.repository.EcoWalletRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class EcoWalletService {

    @Autowired
    private EcoWalletRepository ecoWalletRepository;

    public EcoWalletDto getWalletForUser(String email) {
        EcoWallet wallet = ecoWalletRepository.findByUserEmail(email)
                .orElse(new EcoWallet(email)); // Return empty wallet if not exists
        return EcoWalletDto.fromEntity(wallet);
    }

    public void addPoints(String email, Integer points) {
        if (points == null || points <= 0) return;
        
        Optional<EcoWallet> walletOpt = ecoWalletRepository.findByUserEmail(email);
        EcoWallet wallet;
        if (walletOpt.isPresent()) {
            wallet = walletOpt.get();
            wallet.setTotalPoints(wallet.getTotalPoints() + points);
        } else {
            wallet = new EcoWallet(email);
            wallet.setTotalPoints(points);
        }
        wallet.setLastUpdated(LocalDateTime.now());
        ecoWalletRepository.save(wallet);
    }
}
