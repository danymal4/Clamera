//
//  ShopCatalog.swift
//  Clamera
//
//  Created by Kaes van Dolder on 2026-08.
//

import Foundation

struct ShopCatalog {
    // 1. All available asset targets matching capitalized spacing structure
    static let fishNames = [
        "Alaska Pollock",
        "Albacore Tuna",
        "Allis Shad",
        "American Shad",
        "Arctic Char",
        "Arel Tongue Sole",
        "Atlantic Bonito",
        "Atlantic Chub Mackerel",
        "Atlantic Herring",
        "Atlantic Horse Mackerel",
        "Atlantic Salmon",
        "Atlantic Sturgeon",
        "Atlantic Tarpon",
        "Atoll Butterflyfish",
        "Banded Killifish",
        "Banded Rudderfish",
        "Barramundi",
        "Belanger's Croaker",
        "Bigmouth Buffalo",
        "Black Bullhead",
        "Black Crappie",
        "Black Crappie Variant",
        "Black Goby",
        "Black Rockfish",
        "Black Sea Sprat",
        "Black Seabass",
        "Blackline Tilefish",
        "Blackside Darter",
        "Blackstripe Topminnow",
        "Blacktip Shark",
        "Blue Mackerel",
        "Blue Rockfish",
        "Blue-spotted Cornetfish",
        "Bluefish",
        "Bluegill",
        "Boarfish",
        "Bocaccio Rockfish",
        "Bombay Duck",
        "Bonefish",
        "Brill",
        "Brown Bullhead",
        "Brown Meagre",
        "Brown Rockfish",
        "Brown Trout (River Variant)",
        "Brushtooth Lizardfish",
        "Bullet Tuna",
        "Burbot",
        "Burton's Mouthbrooder",
        "California Flounder",
        "Central Mudminnow",
        "Chain Pickerel",
        "Channel Catfish",
        "Chub Mackerel",
        "Chum Salmon",
        "Clearnose Skate",
        "Cloudy Lizardfish",
        "Coastal Cutthroat Trout",
        "Coho Salmon",
        "Comber",
        "Common Chub",
        "Common Dentex",
        "Common Porgy",
        "Common Snook",
        "Common Sole",
        "Danube Salmon",
        "Darkspotted Snake Eel",
        "Doublelined Tongue Sole",
        "Doublespotted Queenfish",
        "Dusky Flathead",
        "Dusky Grouper",
        "Eastern Atlantic Cod",
        "Eastern Mudminnow",
        "European Hake",
        "European Pilchard",
        "European Seabass",
        "European Sprat",
        "Finescale Dace",
        "Flathead Grey Mullet",
        "Florida Largemouth Bass",
        "Florida Pompano",
        "Fourlined Tongue Sole",
        "Fourspot Flounder",
        "Freshwater Drum",
        "Giant Trevally",
        "Gilthead Seabream",
        "Goldbanded Jobfish",
        "Goldblotch Grouper",
        "Golden Grey Mullet",
        "Golden Redhorse",
        "Golden Shiner",
        "Golden Tilefish",
        "Grass Pickerel",
        "Gray Snapper",
        "Great Barracuda",
        "Greater Lizardfish",
        "Greater Weever",
        "Green Sunfish",
        "Greenland Cod",
        "Gudgeon",
        "Haddock",
        "Hooded Wrasse",
        "Hooknose Tongue Sole",
        "Humpback Red Snapper",
        "Ide",
        "Indian Oil Sardine",
        "Indian Spiny Turbot",
        "Indian Whiting",
        "Inland Cutthroat Trout",
        "Japanese Horse Mackerel",
        "Japanese Tongue Sole",
        "Javelin Grunt (Indian variant)",
        "Johnny Darter",
        "King George Whiting",
        "Lake Sturgeon",
        "Lake Whitefish",
        "Landlocked Twaite Shad",
        "Large Scale Lizardfish",
        "Lesser Weever",
        "Little Tunny",
        "Logperch",
        "Longear Sunfish",
        "Longfin Lizardfish",
        "Longnose Sucker",
        "Longspined Grunt",
        "Longtongue Sole",
        "Longtooth Grouper",
        "Marbled Spinefoot",
        "Mediterranean Horse Mackerel",
        "Megrim",
        "Milkfish",
        "Monkfish",
        "Mottled Sculpin",
        "Mountain Whitefish",
        "Mud Goby",
        "Muskellunge",
        "Narrow-barred Spanish Mackerel",
        "Ocean Sunfish",
        "Ocellaris Clownfish",
        "Orbicular Batfish",
        "Oriental Weatherfish",
        "Pacific Bonefish",
        "Pacific Cod",
        "Pacific Halibut",
        "Pacific Herring",
        "Pacific Sardine",
        "Palette Surgeonfish",
        "Peron's Threadfin Bream",
        "Pink Squirrelfish",
        "Rainbow Trout",
        "Swordfish"
    ]
    
    // Optional manual price overrides dictionary
    static let manualPrices: [String: Int] = [
        "Atlantic Salmon": 500,
        "Ocellaris Clownfish": 1000,
        "Pacific Halibut": 750,
        "Black Crappie Variant": 900,
        "Rainbow Trout": 800,
        "Orbicular Batfish": 955,
        "Boarfish": 890,
        "Milkfish": 745,
        "Monkfish": 700,
        "Bombay Duck": 690,
        "Chum Salmon": 750,
        "Pacific Cod": 600,
        "Ocean Sunfish": 950,
        "Blacktip Shark": 1500,
        "Longear Sunfish": 800,
        "Goldbanded Jobfish": 555,
        "Narrow-barred Spanish Mackerel": 800,
        "Palette Surgeonfish": 1000,
        "Swordfish": 950,
        "Peron's Threadfin Bream": 975,
        "Pink Squirrelfish": 825,
        "Black Rockfish": 625
    ]
     
    // 2. Automated structural translation pipeline
    static var items: [ShopItem] {
        fishNames.map { name in
            let safeId = name.lowercased()
                .replacingOccurrences(of: ", ", with: "_")
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "-", with: "_")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "'", with: "") + "_cosmetic"
              
            // Explicit icon name mapping to match your asset catalog perfectly
            let cleanIconName: String = {
                let manualAssetOverrides: [String: String] = [
                    "Belanger's Croaker": "Belanger's CroakerIcon",
                    "Burton's Mouthbrooder": "Burton's MouthbrooderIcon",
                    "Russel's Snapper": "Russel's SnapperIcon",
                    "Pink Squirrelfish": "Pink SquirrelfishIcon",
                    "Saithe / Coalfish": "Saithe CoalfishIcon",
                    "Peron's Threadfin Bream": "Peron’s Threadfin BreamIcon"
                ]
                
                if let override = manualAssetOverrides[name] {
                    return override
                }
                
                return "\(name)Icon"
            }()
              
            // Check if a manual price exists for this fish, otherwise use the dynamic formula
            let dynamicCost = manualPrices[name] ?? (250 + (name.count * 12))
              
            return ShopItem(
                id: safeId,
                name: "\(name) Icon",
                iconName: cleanIconName,
                baseCost: dynamicCost,
                category: .all
            )
        }
    }
}
