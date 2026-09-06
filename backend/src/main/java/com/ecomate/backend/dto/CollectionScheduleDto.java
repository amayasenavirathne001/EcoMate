package com.ecomate.backend.dto;

public class CollectionScheduleDto {
    private Long id;
    private String scheduleName;
    private Long routeId;
    private RouteDto route;
    private String areaOrZone;
    private String wasteCategoryId;
    private WasteCategoryDto wasteCategory;
    private String collectionDateOrDay;
    private String startTime;
    private String endTime;
    private String frequency;
    private String destinationType;
    private String recyclingCenterId;
    private RecyclingCenterDto recyclingCenter;
    private String status;
    private String resourceStatus;

    public CollectionScheduleDto() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getScheduleName() {
        return scheduleName;
    }

    public void setScheduleName(String scheduleName) {
        this.scheduleName = scheduleName;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public RouteDto getRoute() {
        return route;
    }

    public void setRoute(RouteDto route) {
        this.route = route;
    }

    public String getAreaOrZone() {
        return areaOrZone;
    }

    public void setAreaOrZone(String areaOrZone) {
        this.areaOrZone = areaOrZone;
    }

    public String getWasteCategoryId() {
        return wasteCategoryId;
    }

    public void setWasteCategoryId(String wasteCategoryId) {
        this.wasteCategoryId = wasteCategoryId;
    }

    public WasteCategoryDto getWasteCategory() {
        return wasteCategory;
    }

    public void setWasteCategory(WasteCategoryDto wasteCategory) {
        this.wasteCategory = wasteCategory;
    }

    public String getCollectionDateOrDay() {
        return collectionDateOrDay;
    }

    public void setCollectionDateOrDay(String collectionDateOrDay) {
        this.collectionDateOrDay = collectionDateOrDay;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getFrequency() {
        return frequency;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public String getDestinationType() {
        return destinationType;
    }

    public void setDestinationType(String destinationType) {
        this.destinationType = destinationType;
    }

    public String getRecyclingCenterId() {
        return recyclingCenterId;
    }

    public void setRecyclingCenterId(String recyclingCenterId) {
        this.recyclingCenterId = recyclingCenterId;
    }

    public RecyclingCenterDto getRecyclingCenter() {
        return recyclingCenter;
    }

    public void setRecyclingCenter(RecyclingCenterDto recyclingCenter) {
        this.recyclingCenter = recyclingCenter;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResourceStatus() {
        return resourceStatus;
    }

    public void setResourceStatus(String resourceStatus) {
        this.resourceStatus = resourceStatus;
    }
}
