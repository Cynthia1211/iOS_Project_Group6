//
//  Treasure.swift
//  Project-Group6
//
//  Created by YueZhang on 2026-07-05.
//

import Foundation

// Define Treasure Class
class Treasure {
    var id: String
    var title: String
    var treasureDescription: String
    var treasureMessage: String
    var latitude: Double
    var longitude: Double
    var validationCode: String
    var points: Int
    var isTreasureFound: Bool
    var treasurePlaceBy: String
    var treasureFoundby: String
    
    init(id: String = UUID().uuidString, title: String, treasureDescription: String,
                treasureMessage: String = "Status pending...", latitude: Double, longitude: Double,
                validationCode: String, points: Int = 100, isTreasureFound: Bool = false,
                treasurePlaceBy: String, treasureFoundby: String = "") {
        self.id = id
        self.title = title
        self.treasureDescription = treasureDescription
        self.treasureMessage = treasureMessage
        self.latitude = latitude
        self.longitude = longitude
        self.validationCode = validationCode
        self.points = points
        self.isTreasureFound = isTreasureFound
        self.treasurePlaceBy = treasurePlaceBy
        self.treasureFoundby = treasureFoundby
        }
    }

    // MockData. To be removed after SQLlite included
    struct MockData {
        static var treasures: [Treasure] = [
            Treasure(
                title: "Square One Secret Box",
                treasureDescription: "Hidden near the food court entrance inside the mall.",
                treasureMessage: "Clue: Look behind the digital directory screen.",
                latitude: 43.5935, longitude: -79.6425,
                validationCode: "SQ1FOOD", points: 150,
                isTreasureFound: false, treasurePlaceBy: "Alex"
            ),
            Treasure(
                title: "Erindale Park Capsule",
                treasureDescription: "Buried near the main trail bridge over the river.",
                treasureMessage: "Claimed successfully! 🎉",
                latitude: 43.5468, longitude: -79.6621,
                validationCode: "RIVER2026", points: 200,
                isTreasureFound: true, treasurePlaceBy: "Sophie", treasureFoundby: "Yue"
            ),
            Treasure(
                title: "Port Credit Lighthouse Stash",
                treasureDescription: "Right by the historic lighthouse deck overlooking the lake.",
                treasureMessage: "Status pending...",
                latitude: 43.5512, longitude: -79.5864,
                validationCode: "LAKEVIEW99", points: 250,
                isTreasureFound: false, treasurePlaceBy: "Tram"
            ),
            Treasure(
                title: "Sheridan B-Wing Tech Chest",
                treasureDescription: "Near the game development lab vending machines.",
                treasureMessage: "Claimed by Yue! Good job.",
                latitude: 43.4691, longitude: -79.6982,
                validationCode: "SHERIDAN31632", points: 100,
                isTreasureFound: true, treasurePlaceBy: "Alex", treasureFoundby: "Yue"
            ),
            Treasure(
                title: "Oakville Place Mall Trophy",
                treasureDescription: "Hidden near the central fountain on the lower level.",
                treasureMessage: "Clue: It's under the bench near the elevator.",
                latitude: 43.4612, longitude: -79.6845,
                validationCode: "OAKMALL55", points: 120,
                isTreasureFound: false, treasurePlaceBy: "Sophie"
            ),
            Treasure(
                title: "Bronte Creek Valley Cache",
                treasureDescription: "Deep inside the provincial park near the camping ground.",
                treasureMessage: "Status pending...",
                latitude: 43.4150, longitude: -79.7530,
                validationCode: "BRONTEWILD", points: 300,
                isTreasureFound: false, treasurePlaceBy: "Tram"
            )
        ]
    }
