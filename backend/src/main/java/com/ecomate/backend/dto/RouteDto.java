package com.ecomate.backend.dto;

public class RouteDto {
    private Long id;
    private String routeCode;
    private String routeName;
    private String areaOrZone;
    private String description;
    private String status;

    public RouteDto() {
    }

    public RouteDto(Long id, String routeCode, String routeName, String areaOrZone, String description, String status) {
        this.id = id;
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
