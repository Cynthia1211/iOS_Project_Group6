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
