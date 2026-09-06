package com.ecomate.backend.service;

import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.*;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DataSeederService {

    private final WasteCategoryRepository wasteCategoryRepository;
    private final RecyclingCenterRepository recyclingCenterRepository;
    private final RouteRepository routeRepository;

    public DataSeederService(WasteCategoryRepository wasteCategoryRepository,
                             RecyclingCenterRepository recyclingCenterRepository,
                             RouteRepository routeRepository) {
        this.wasteCategoryRepository = wasteCategoryRepository;
        this.recyclingCenterRepository = recyclingCenterRepository;
        this.routeRepository = routeRepository;
    }

    @PostConstruct
    @Transactional
    public void seedData() {
        // Seed Waste Categories
        if (wasteCategoryRepository.count() == 0) {
            wasteCategoryRepository.saveAll(List.of(
                new WasteCategory("plastics", "Plastics", true),
                new WasteCategory("paper", "Paper & Cardboard", true),
                new WasteCategory("glass", "Glass", true),
                new WasteCategory("metals", "Metals & Cans", true),
                new WasteCategory("organic", "Organic & Compost", true),
                new WasteCategory("e_waste", "E-Waste (Electronics)", true),
                new WasteCategory("hazardous", "Hazardous & Medical Waste", false)
            ));
        }

        // Seed Recycling Centers
        if (recyclingCenterRepository.count() == 0) {
            recyclingCenterRepository.saveAll(List.of(
                new RecyclingCenter(
                    "rc_01",
                    "GreenCycle Central Hub",
                    "No. 45 Baseline Road, Colombo 09",
                    "Colombo",
                    1.2,
                    "+94 11 268 4590",
                    "contact@greencyclehub.lk",
                    "Mon - Sat: 8:00 AM - 5:30 PM",
                    true,
                    List.of(
                        "Plastic Bottles (PET #1)",
                        "Rigid Plastics (HDPE #2, PP #5)",
                        "Cardboard & Office Paper",
                        "Aluminum & Tin Cans",
                        "Glass Bottles & Jars"
                    ),
                    "Offers drop-off points for bulk recyclables. Weight-based incentives provided."
                ),
                new RecyclingCenter(
                    "rc_02",
                    "EcoTech E-Waste Recovery Centre",
                    "120 High Level Road, Maharagama",
                    "Maharagama",
                    3.8,
                    "+94 11 285 9940",
                    "info@ecotech-recovery.lk",
                    "Tue - Sun: 9:00 AM - 6:00 PM",
                    true,
                    List.of(
                        "Mobile Phones & Tablets",
                        "Computers, Monitors & Laptops",
                        "Batteries & Power Banks",
                        "Cables, Adapters & Small Appliances",
                        "Fluorescent Bulbs"
                    ),
                    "Specialized authorized e-waste facility. Free certified data wiping on computer drives."
                ),
                new RecyclingCenter(
                    "rc_03",
                    "BioRecycle Organic Composting Plant",
                    "88 Temple Road, Nawala, Rajagiriya",
                    "Rajagiriya",
                    4.5,
                    "+94 11 442 1102",
                    "support@biorecycle.org",
                    "Mon - Fri: 7:30 AM - 4:00 PM",
                    true,
                    List.of(
                        "Fruit & Vegetable Scraps",
                        "Garden Leaves & Grass Clippings",
                        "Coffee Grounds & Tea Leaves",
                        "Eggshells & Biodegradable Packaging"
                    ),
                    "Free organic compost bag exchange for every 10kg of kitchen waste delivered."
                ),
                new RecyclingCenter(
                    "rc_04",
                    "MetalWorks Recycling & Scrap Yard",
                    "15 Industrial Zone, Kelaniya",
                    "Kelaniya",
                    6.2,
                    "+94 11 291 0334",
                    "metals@scrapworks.lk",
                    "Mon - Sat: 8:30 AM - 5:00 PM",
                    false,
                    List.of(
                        "Aluminum Beverage Cans",
                        "Steel Food Tins",
                        "Copper Wires & Brass Fittings",
                        "Old Metal Cookware & Roof Sheets"
                    ),
                    "Instant cash payouts for scrap metals based on daily market weight rates."
                ),
                new RecyclingCenter(
                    "rc_05",
                    "Urban Clean Glass & Paper Depot",
                    "202 Galle Road, Dehiwala",
                    "Dehiwala",
                    5.1,
                    "+94 11 273 8819",
                    "depot@urbanclean.lk",
                    "Mon - Sat: 8:00 AM - 6:00 PM",
                    true,
                    List.of(
                        "Clear & Colored Glass Bottles",
                        "Glass Food Jars",
                        "Cardboard Boxes & Newspapers",
                        "Office Shredded Paper"
                    ),
                    "Drive-through drop-off lane available for quick unloading of cartons and glass crates."
                )
            ));
        }

        // Seed Routes
        if (routeRepository.count() == 0) {
            routeRepository.saveAll(List.of(
                new Route("ROUTE-A", "Route A - Greenfield Residential", "Zone A", "Covers primary residential area of Greenfield", "ACTIVE"),
                new Route("ROUTE-B", "Route B - Lakeview Mixed Collection", "Zone B", "Mixed residential and light retail along the lakeview drive", "ACTIVE"),
                new Route("ROUTE-C", "Route C - Riverside Commercial", "Zone C", "Commercial complexes and offices along the Riverside bank", "ACTIVE")
            ));
        }
    }
}
