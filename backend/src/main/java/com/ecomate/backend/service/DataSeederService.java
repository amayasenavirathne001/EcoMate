package com.ecomate.backend.service;


import com.ecomate.backend.entity.Route;
import com.ecomate.backend.entity.WasteCategory;

import com.ecomate.backend.repository.RouteRepository;
import com.ecomate.backend.repository.WasteCategoryRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Arrays;

@Service
public class DataSeederService {

    private final WasteCategoryRepository wasteCategoryRepository;
    
    private final RouteRepository routeRepository;

    public DataSeederService(WasteCategoryRepository wasteCategoryRepository,
                             
                             RouteRepository routeRepository) {
        this.wasteCategoryRepository = wasteCategoryRepository;
        
        this.routeRepository = routeRepository;
    }

    @PostConstruct
    @Transactional
    public void seedData() {
        if (wasteCategoryRepository.count() > 0) return; // ONLY SEED IF EMPTY
        // Seed Waste Categories with full mock data for the UI
        WasteCategory plastics = new WasteCategory("plastics", "Plastics", true);
        plastics.setBinColorName("Orange / Yellow Bin");
        plastics.setBinColor("0xFFF59E0B");
        plastics.setIcon("local_drink_rounded");
        plastics.setDescription("Clean and dry recyclable plastics such as bottles, containers, and rigid packaging.");
        plastics.setCommonItems(Arrays.asList("PET Water & Soda Bottles (#1)", "HDPE Milk & Detergent Jugs (#2)", "PP Food Containers & Tubs (#5)", "Plastic bottle caps (attached)", "Clean plastic cosmetic bottles"));
        plastics.setPreparationSteps(Arrays.asList("Empty all liquids and contents completely.", "Rinse thoroughly with clean water to remove food residue.", "Crush or compress plastic bottles to save bin space.", "Keep caps screwed onto the bottle or place loose inside."));
        plastics.setDos(Arrays.asList("Rinse items thoroughly before disposal", "Check resin identification codes (#1, #2, #5)"));
        plastics.setDonts(Arrays.asList("Do not include plastic bags or film (they tangle machinery)", "Do not recycle toys, PVC (#3), or Styrofoam (#6)"));

        WasteCategory paper = new WasteCategory("paper", "Paper & Cardboard", true);
        paper.setBinColorName("Blue Bin");
        paper.setBinColor("0xFF3B82F6");
        paper.setIcon("article_rounded");
        paper.setDescription("Dry, clean paper, cardboard boxes, newspapers, and non-waxed cartons.");
        paper.setCommonItems(Arrays.asList("Corrugated shipping & parcel boxes", "Cereal & dry food packaging boxes", "Newspapers, magazines, and flyers", "Office printer paper and envelopes", "Egg cartons (clean paperboard)"));
        paper.setPreparationSteps(Arrays.asList("Flatten all cardboard boxes completely.", "Remove any plastic packing tape and polystyrene inside.", "Keep dry - wet paper cannot be processed at recycling plants."));
        paper.setDos(Arrays.asList("Keep paper and cardboard completely dry", "Flatten boxes to save space"));
        paper.setDonts(Arrays.asList("Do not include greasy pizza boxes or food-soiled paper", "Do not include shredded paper (unless bagged properly)"));

        WasteCategory glass = new WasteCategory("glass", "Glass", true);
        glass.setBinColorName("Green Bin");
        glass.setBinColor("0xFF10B981");
        glass.setIcon("wine_bar_rounded");
        glass.setDescription("Intact glass bottles, beverage containers, and food jars (clear, brown, green).");
        glass.setCommonItems(Arrays.asList("Glass beverage & soda bottles", "Glass jam, sauce, and pickle jars", "Glass condiment & oil bottles", "Glass cosmetic jars (rinsed)"));
        glass.setPreparationSteps(Arrays.asList("Rinse thoroughly to remove all food and sauce traces.", "Remove metal or plastic caps and lids (recycle separately).", "Do not break - keep glass containers intact for safety."));
        glass.setDos(Arrays.asList("Separate caps and lids from glass bottles", "Rinse out all food and liquid residue"));
        glass.setDonts(Arrays.asList("Do not include broken glass, windows, or mirrors", "Do not include drinking glasses or Pyrex ovenware"));

        WasteCategory metals = new WasteCategory("metals", "Metals & Cans", true);
        metals.setBinColorName("Silver / Grey Bin");
        metals.setBinColor("0xFF64748B");
        metals.setIcon("takeout_dining_rounded");
        metals.setDescription("Aluminum cans, steel food tins, clean foil trays, and clean metal jar lids.");
        metals.setCommonItems(Arrays.asList("Aluminum beverage & soda cans", "Steel/tin soup, fish, and vegetable cans", "Clean aluminum foil and baking trays", "Metal bottle caps and jar lids", "Empty aerosol spray cans (completely discharged)"));
        metals.setPreparationSteps(Arrays.asList("Rinse clean of all sauces, liquids, and oils.", "Crush beverage cans to save bin volume.", "Push metal lids inside the cans for safety."));
        metals.setDos(Arrays.asList("Clean out all food residue from cans", "Crush cans to save space"));
        metals.setDonts(Arrays.asList("Do not include sharp or rusty metal scraps", "Do not include aerosol cans that still contain gas/liquid"));

                WasteCategory organic = new WasteCategory("organic", "Organic & Compost", true);
        organic.setBinColorName("Green Compost Bin");
        organic.setBinColor("0xFF22C55E");
        organic.setIcon("eco_rounded");
        organic.setDescription("Biodegradable kitchen scraps, fruit peels, leftover cooked food, and yard trimmings.");
        organic.setCommonItems(Arrays.asList("Fruit and vegetable peels & scraps", "Coffee grounds and unbleached paper filters", "Eggshells and nut shells", "Garden leaves and twigs"));
        organic.setPreparationSteps(Arrays.asList("Drain excess liquids and gravy from food scraps.", "Collect in a compostable bag or dedicated organic bin."));
        organic.setDos(Arrays.asList("Keep compost aerated", "Balance green and brown waste"));
        organic.setDonts(Arrays.asList("Do not include plastic packaging", "Do not add meat or dairy to basic home composts"));

        WasteCategory e_waste = new WasteCategory("e_waste", "E-Waste (Electronics)", true);
        e_waste.setBinColorName("Designated E-Waste Drop-off");
        e_waste.setBinColor("0xFF8B5CF6");
        e_waste.setIcon("devices_other_rounded");
        e_waste.setDescription("Disused electrical items, computers, mobile phones, batteries, and accessories.");
        e_waste.setCommonItems(Arrays.asList("Mobile Phones & Tablets", "Chargers, USB Cables & Power Banks", "Laptops & Desktop Components", "Keyboards & Mice"));
        e_waste.setPreparationSteps(Arrays.asList("Perform a factory reset and remove personal data.", "Bundle cords neatly with a rubber band.", "Drop off at an authorized E-Waste center."));
        e_waste.setDos(Arrays.asList("Wipe personal data before disposal", "Remove batteries if possible"));
        e_waste.setDonts(Arrays.asList("Do not throw in general waste bin", "Do not disassemble dangerous components like CRT monitors"));

        WasteCategory hazardous = new WasteCategory("hazardous", "Hazardous & Medical Waste", false);
        hazardous.setBinColorName("Red Bin (Special)");
        hazardous.setBinColor("0xFFEF4444");
        hazardous.setIcon("warning_rounded");
        hazardous.setDescription("Dangerous, toxic, or medical waste requiring special handling.");
        hazardous.setCommonItems(Arrays.asList("Used syringes and needles", "Expired medications", "Paints, solvents, and chemicals", "Fluorescent light bulbs"));
        hazardous.setPreparationSteps(Arrays.asList("Seal medical waste in puncture-proof containers.", "Keep chemicals in original labeled containers."));
        hazardous.setDos(Arrays.asList("Handle with extreme care and protective gear", "Use designated disposal facilities"));
        hazardous.setDonts(Arrays.asList("NEVER mix chemicals", "NEVER throw in regular household bins"));

        wasteCategoryRepository.saveAll(Arrays.asList(plastics, paper, glass, metals, organic, e_waste, hazardous));

        // Seed Recycling Centers
        // DISABLED to prevent duplicate table population for mock RecyclingCenter
        /*
        if (recyclingCenterRepository.count() == 0) {
            ...
        }
        */

        // Seed Routes
        if (routeRepository.count() == 0) {
            routeRepository.saveAll(List.of(
                new Route("ROUTE-A", "Route A - Greenfield Residential", "Zone A", "Covers primary residential area of Greenfield", "ACTIVE"),
                new Route("ROUTE-B", "Route B - Downtown Commercial", "Zone B", "Commercial district and main street shops", "ACTIVE"),
                new Route("ROUTE-C", "Route C - Westside Industrial", "Zone C", "Industrial park and large facility collection", "ACTIVE")
            ));
        }
    }
}





