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
    var treasureMessage: String
    var latitude: Double
    var longitude: Double
    var validationCode: String
    var points: Int
    var isTreasureFound: Bool
    var treasurePlaceBy: String // UUID
    var treasureFoundby: String // UUID
    
    init(id: String = UUID().uuidString, title: String, treasureMessage: String = "",
            latitude: Double, longitude: Double, validationCode: String, points: Int = 100,
            isTreasureFound: Bool = false, treasurePlaceBy: String, treasureFoundby: String = "") {
        self.id = id
        self.title = title
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
                treasureMessage: "Clue: Look behind the digital directory screen.",
                latitude: 43.5935, longitude: -79.6425,
                validationCode: "SQ1FOOD", points: 150,
                isTreasureFound: false, treasurePlaceBy: "user_id_222"
            ),
            Treasure(
                title: "Erindale Park Capsule",
                treasureMessage: "Claimed successfully! 🎉",
                latitude: 43.5468, longitude: -79.6621,
                validationCode: "RIVER2026", points: 200,
                isTreasureFound: true, treasurePlaceBy: "user_id_333", treasureFoundby: "user_id_111"
            ),
            Treasure(
                title: "Port Credit Lighthouse Stash",
                treasureMessage: "Right by the historic lighthouse deck overlooking the lake.",
                latitude: 43.5512, longitude: -79.5864,
                validationCode: "LAKEVIEW99", points: 250,
                isTreasureFound: false, treasurePlaceBy: "user_id_444"
            ),
            Treasure(
                title: "Sheridan B-Wing Tech Chest",
                treasureMessage: "Near the game development lab vending machines.",
                latitude: 43.4691, longitude: -79.6982,
                validationCode: "SHERIDAN31632", points: 100,
                isTreasureFound: true, treasurePlaceBy: "user_id_222", treasureFoundby: "user_id_111"
            ),
            Treasure(
                title: "Oakville Place Mall Trophy",
                treasureMessage: "Clue: It's under the bench near the elevator.",
                latitude: 43.4612, longitude: -79.6845,
                validationCode: "OAKMALL55", points: 120,
                isTreasureFound: false, treasurePlaceBy: "user_id_333"
            ),
            Treasure(
                title: "Bronte Creek Valley Cache",
                treasureMessage: "Status pending...",
                latitude: 43.4150, longitude: -79.7530,
                validationCode: "BRONTEWILD", points: 300,
                isTreasureFound: false, treasurePlaceBy: "user_id_444"
            ),
            Treasure(
                title: "Celebration Square Zero Point",
                treasureMessage: "Waiting to be found! 👑",
                latitude: 43.5997071, longitude: -79.6521141,
                validationCode: "MISSISSAUGA1", points: 500,
                isTreasureFound: false, treasurePlaceBy: "user_id_111"
            ),
            Treasure(
                title: "Sheridan Trapper Hideout",
                treasureMessage: "Waiting to be found! 🏫",
                latitude: 43.4677987, longitude: -79.6998490,
                validationCode: "SHERIDAN2026", points: 500,
                isTreasureFound: false, treasurePlaceBy: "user_id_111"
            )
        ]
    }
