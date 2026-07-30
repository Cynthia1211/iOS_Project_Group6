//
//  Treasure.swift
//  Project-Group6
//
//  Created by YueZhang on 2026-07-05.
//

import Foundation

// Author: Yue Zhang
// Description: Defines the Treasure class to wrap treasure database records into Treasure objects.
class Treasure {
    var id: String // Unique ID of the treasure
    var title: String // Title of the treasure
    var treasureMessage: String // Message or hint for finding the treasure
    var latitude: Double // Latitude coordinate of the treasure location
    var longitude: Double // Longitude coordinate of the treasure location
    var validationCode: String // Code used to verify and claim the treasure
    var points: Int // Reward points given when found
    var isTreasureFound: Bool // True if the treasure has been found
    var treasurePlaceBy: String // UUID of the person who hid the treasure
    var treasureFoundby: String // UUID of the person who found the treasure
    
    // Initializes a new Treasure object with default values.
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
