//
//  TreasureManager.swift
//  Project-Group6
//
//  Created by Yue Zhang on 2026-07-18.
//

import Foundation
import SQLite3
import UIKit

class TreasureManager {
    static let shared = TreasureManager()
    
    private var databasePath: String? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.databasePath
        }
        return nil
    }
    
    func fetchTreasuresAround(centerLat: Double, centerLon: Double, halfSideLengthInMeters: Double) -> [Treasure] {
        var treasures = [Treasure]()
        var db: OpaquePointer? = nil
        guard let path = databasePath else { return treasures }
        
        let latDelta = halfSideLengthInMeters / 111000.0
        let lonDelta = halfSideLengthInMeters / 80000.0
        
        let minLat = centerLat - latDelta
        let maxLat = centerLat + latDelta
        let minLon = centerLon - lonDelta
        let maxLon = centerLon + lonDelta
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            let querySQL = """
            SELECT *  FROM treasures 
            WHERE isTreasureFound = 0 AND latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?
            """
            
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_double(statement, 1, minLat)
                sqlite3_bind_double(statement, 2, maxLat)
                sqlite3_bind_double(statement, 3, minLon)
                sqlite3_bind_double(statement, 4, maxLon)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = String(cString: sqlite3_column_text(statement, 0))
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    let message = String(cString: sqlite3_column_text(statement, 2))
                    let lat = sqlite3_column_double(statement, 3)
                    let lon = sqlite3_column_double(statement, 4)
                    let code = String(cString: sqlite3_column_text(statement, 5))
                    let pts = Int(sqlite3_column_int(statement, 6))
                    let isFound = sqlite3_column_int(statement, 7) == 1
                    let placedBy = String(cString: sqlite3_column_text(statement, 8))
                    let foundBy = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)!) : ""
                    
                    let treasure = Treasure(
                        id: id, title: title, treasureMessage: message,
                        latitude: lat, longitude: lon, validationCode: code, points: pts,
                        isTreasureFound: isFound, treasurePlaceBy: placedBy, treasureFoundby: foundBy
                    )
                    treasures.append(treasure)
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }

        return treasures
    }
    
    func markTreasureAsFound(treasureId: String, foundByUserId: String) -> Bool {
        var db: OpaquePointer? = nil
        var success = false
        guard let path = databasePath else { return false }
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            let updateSQL = "UPDATE treasures SET isTreasureFound = 1, treasureFoundby = ? WHERE id = ?"
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (foundByUserId as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (treasureId as NSString).utf8String, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    success = true
                    print("Treasure status updated successfully.")
                } else {
                    print("ERROR: Failed to update treasure status.")
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }
        return success
    }
    

    func updateUserScore(userUUID: String, additionalPoints: Int) -> Bool {
        var db: OpaquePointer? = nil
        var success = false
        guard let path = databasePath else { return false }
        
        if sqlite3_open(path, &db) == SQLITE_OK {

            let updateSQL = "UPDATE entries SET score = score + ? WHERE uuid = ?"
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(additionalPoints))
                sqlite3_bind_text(statement, 2, (userUUID as NSString).utf8String, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    success = true
                    print("User \(userUUID) score updated (+ \(additionalPoints) points).")
                } else {
                    print("ERROR: Failed to update user score.")
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }
        return success
    }
    
    func searchTreasureByPlaceBy(userUUID: String) -> [Treasure] {
        var treasures = [Treasure]()
        var db: OpaquePointer? = nil
        guard let path = databasePath else { return treasures }
        
        if sqlite3_open(path, &db) == SQLITE_OK {

            let querySQL = """
            SELECT * FROM treasures WHERE treasurePlaceBy = ?
            """
            
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {

                sqlite3_bind_text(statement, 1, (userUUID as NSString).utf8String, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = String(cString: sqlite3_column_text(statement, 0))
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    let message = String(cString: sqlite3_column_text(statement, 2))
                    let lat = sqlite3_column_double(statement, 3)
                    let lon = sqlite3_column_double(statement, 4)
                    let code = String(cString: sqlite3_column_text(statement, 5))
                    let pts = Int(sqlite3_column_int(statement, 6))
                    let isFound = sqlite3_column_int(statement, 7) == 1
                    let placedBy = String(cString: sqlite3_column_text(statement, 8))
                    let foundBy = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)!) : ""
                    
                    let treasure = Treasure(
                        id: id, title: title, treasureMessage: message,
                        latitude: lat, longitude: lon, validationCode: code, points: pts,
                        isTreasureFound: isFound, treasurePlaceBy: placedBy, treasureFoundby: foundBy
                    )
                    treasures.append(treasure)
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }

        return treasures
    }

    func searchTreasureByFoundBy(userUUID: String) -> [Treasure] {
        var treasures = [Treasure]()
        var db: OpaquePointer? = nil
        guard let path = databasePath else { return treasures }
        
        if sqlite3_open(path, &db) == SQLITE_OK {

            let querySQL = """
            SELECT * FROM treasures WHERE isTreasureFound = 1 AND treasureFoundby = ?
            """
            
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {

                sqlite3_bind_text(statement, 1, (userUUID as NSString).utf8String, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = String(cString: sqlite3_column_text(statement, 0))
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    let message = String(cString: sqlite3_column_text(statement, 2))
                    let lat = sqlite3_column_double(statement, 3)
                    let lon = sqlite3_column_double(statement, 4)
                    let code = String(cString: sqlite3_column_text(statement, 5))
                    let pts = Int(sqlite3_column_int(statement, 6))
                    let isFound = sqlite3_column_int(statement, 7) == 1
                    let placedBy = String(cString: sqlite3_column_text(statement, 8))
                    let foundBy = sqlite3_column_text(statement, 9) != nil ? String(cString: sqlite3_column_text(statement, 9)!) : ""
                    
                    let treasure = Treasure(
                        id: id, title: title, treasureMessage: message,
                        latitude: lat, longitude: lon, validationCode: code, points: pts,
                        isTreasureFound: isFound, treasurePlaceBy: placedBy, treasureFoundby: foundBy
                    )
                    treasures.append(treasure)
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }

        return treasures
    }
    

    func addNewTreasure(treasure: Treasure) -> Bool {
        var db: OpaquePointer? = nil
        guard let path = databasePath else { return false }
        var isSuccess = false
        
        if sqlite3_open(path, &db) == SQLITE_OK {

            let insertSQL = """
            INSERT INTO treasures (id, title, treasureMessage, latitude, longitude, validationCode, points, isTreasureFound, treasurePlaceBy, treasureFoundby) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """
            
            var statement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {

                sqlite3_bind_text(statement, 1, (treasure.id as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (treasure.title as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (treasure.treasureMessage as NSString).utf8String, -1, nil)
                sqlite3_bind_double(statement, 4, treasure.latitude)
                sqlite3_bind_double(statement, 5, treasure.longitude)
                sqlite3_bind_text(statement, 6, (treasure.validationCode as NSString).utf8String, -1, nil)
                sqlite3_bind_int(statement, 7, Int32(treasure.points))
                sqlite3_bind_int(statement, 8, treasure.isTreasureFound ? 1 : 0)
                sqlite3_bind_text(statement, 9, (treasure.treasurePlaceBy as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 10, (treasure.treasureFoundby as NSString).utf8String, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("New treasure '\(treasure.title)' added to database.")
                    isSuccess = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Error inserting treasure: \(errmsg)")
                }
                
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }
        
        return isSuccess
    }
    
    
    // Temp use
    func printRealDatabaseStatus(for treasureId: String, userUUID: String) {
        var db: OpaquePointer? = nil
        guard let path = databasePath else { return }
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            
            let treasureSQL = "SELECT title, isTreasureFound, treasureFoundby FROM treasures WHERE id = ?"
            var treasureStatement: OpaquePointer? = nil
            
            var dbTitle = "Unknown"
            var dbIsFound = false
            var dbFoundBy = "None"
            
            if sqlite3_prepare_v2(db, treasureSQL, -1, &treasureStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(treasureStatement, 1, (treasureId as NSString).utf8String, -1, nil)
                if sqlite3_step(treasureStatement) == SQLITE_ROW {
                    let cTitle = sqlite3_column_text(treasureStatement, 0)
                    let isFoundInt = sqlite3_column_int(treasureStatement, 1)
                    let cFoundBy = sqlite3_column_text(treasureStatement, 2)
                    
                    dbTitle = cTitle != nil ? String(cString: cTitle!) : "Unknown"
                    dbIsFound = (isFoundInt == 1)
                    dbFoundBy = cFoundBy != nil ? String(cString: cFoundBy!) : "None"
                }
                sqlite3_finalize(treasureStatement)
            }
            
            let userSQL = "SELECT score, Username FROM entries WHERE uuid = ?"
            var userStatement: OpaquePointer? = nil
            var dbScore: Int = 0
            var dbUsername = "Unknown"
            
            if sqlite3_prepare_v2(db, userSQL, -1, &userStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(userStatement, 1, (userUUID as NSString).utf8String, -1, nil)
                if sqlite3_step(userStatement) == SQLITE_ROW {
                    dbScore = Int(sqlite3_column_int(userStatement, 0))
                    if let cUsername = sqlite3_column_text(userStatement, 1) {
                        dbUsername = String(cString: cUsername)
                    }
                }
                sqlite3_finalize(userStatement)
            }
            
            print("========================================")
            print("DATABASE REAL-TIME RECORD:")
            print("Player Username: \(dbUsername)")
            print("Player Current Score in DB: \(dbScore) points")
            print("----------------------------------------")
            print("Treasure Title: \(dbTitle)")
            print("IsFound in DB: \(dbIsFound)")
            print("Found By in DB (Real UUID): \(dbFoundBy)")
            print("========================================")
            
            sqlite3_close(db)
        }
    }
}
