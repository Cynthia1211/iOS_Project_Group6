//
//  TreasureAnnotation.swift
//  Project-Group6
//
//  Created by Yue Zhang on 2026-07-05.
//

import Foundation
import MapKit

class TreasureAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    var treasure: Treasure
    
    init(treasure: Treasure) {
        self.treasure = treasure
        self.coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        self.title = treasure.title
        self.subtitle = treasure.treasureMessage
    }
}
