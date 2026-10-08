package com.ecomate.backend.dto;

import com.ecomate.backend.entity.EcoWallet;

public class EcoWalletDto {
    private String userEmail;
    private Integer totalPoints;

    public EcoWalletDto(String userEmail, Integer totalPoints) {
        this.userEmail = userEmail;
        this.totalPoints = totalPoints;
    }

    public static EcoWalletDto fromEntity(EcoWallet entity) {
        return new EcoWalletDto(entity.getUserEmail(), entity.getTotalPoints());
    }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public Integer getTotalPoints() { return totalPoints; }
    public void setTotalPoints(Integer totalPoints) { this.totalPoints = totalPoints; }
}
