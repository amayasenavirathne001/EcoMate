package com.ecomate.backend.dto;

public record OperationsOverviewDto(
    int collectionsCompleted,
    int collectionsTotal,
    int trucksOnRoute,
    int trucksTotal,
    double wasteCollectedTons,
    double wasteTotalTons,
    double recyclingCollectedTons,
    double recyclingTotalTons
) {}
