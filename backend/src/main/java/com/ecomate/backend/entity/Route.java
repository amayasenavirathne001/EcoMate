package com.ecomate.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "routes")
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String routeCode;

    @Column(nullable = false)
    private String routeName;

    @Column(nullable = false)
    private String areaOrZone;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private String status = "ACTIVE"; // ACTIVE, INACTIVE

    public Route() {
    }

    public Route(String routeCode, String routeName, String areaOrZone, String description, String status) {
        this.routeCode = routeCode;
        this.routeName = routeName;
        this.areaOrZone = areaOrZone;
        this.description = description;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRouteCode() {
        return routeCode;
    }

    public void setRouteCode(String routeCode) {
        this.routeCode = routeCode;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public String getAreaOrZone() {
        return areaOrZone;
    }

    public void setAreaOrZone(String areaOrZone) {
        this.areaOrZone = areaOrZone;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
