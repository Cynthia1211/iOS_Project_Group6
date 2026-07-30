//
//  TreasureAnnotation.swift
//  Project-Group6
//
//  Created by Yue Zhang on 2026-07-05.
//

import Foundation
import MapKit

// Author: Yue Zhang
// Description: Custom map pin class to display a Treasure object on MapKit view.
class TreasureAnnotation: NSObject, MKAnnotation {
    
    // Map coordinate (Latitude and Longitude)
    var coordinate: CLLocationCoordinate2D
    
    // Pin title shown on the map
    var title: String?
    
    // Pin subtitle shown on the map
    var subtitle: String?
    
    // Add treasure into pin
    var treasure: Treasure
    
    // Initializes map annotation using data with a Treasure object.
    // Sets up pin coordinates and title text from the treasure model.
    init(treasure: Treasure) {
        self.treasure = treasure
        self.coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        self.title = treasure.title
        self.subtitle = treasure.treasureMessage
    }
}
