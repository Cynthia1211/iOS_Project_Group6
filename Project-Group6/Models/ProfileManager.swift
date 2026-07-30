//
//  ProfileManager.swift
//  Project_Group6
//
//  Created by Cena Nguyen on 2026-07-14.
//

import Foundation
import UIKit
import SQLite3

/**
 Principal Author: Cena Nguyen

 Description:
 This class manages retrieving and storing user profile information.
 It separates profile data logic from ProfileViewController
 to keep the view controller responsible only for UI updates.
 */
class ProfileManager {
    
    private let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var databasePath: String? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.databasePath
        }

        return nil
    }
    
    func getUser(username: String) -> PeopleData? {
        return mainDelegate.people.first {
            $0.username == username
        }
    }
    
    func updateUserInfo(
        currentUsername: String,
        newUsername: String,
        newEmail: String
    ) -> Bool {

        var db: OpaquePointer?
        var updateStatement: OpaquePointer?

        guard let databasePath = databasePath else {
            print("Database path is unavailable.")
            return false
        }

        if sqlite3_open(databasePath, &db) != SQLITE_OK {
            print("Unable to open database.")
            return false
        }

        let queryStatement = """
        UPDATE entries
        SET Username = ?, Email = ?
        WHERE Username = ?
        """

        if sqlite3_prepare_v2(
            db,
            queryStatement,
            -1,
            &updateStatement,
            nil
        ) != SQLITE_OK {
            print("Could not prepare update statement.")
            print(String(cString: sqlite3_errmsg(db)))
            sqlite3_close(db)
            return false
        }

        sqlite3_bind_text(
            updateStatement,
            1,
            (newUsername as NSString).utf8String,
            -1,
            nil
        )

        sqlite3_bind_text(
            updateStatement,
            2,
            (newEmail as NSString).utf8String,
            -1,
            nil
        )

        sqlite3_bind_text(
            updateStatement,
            3,
            (currentUsername as NSString).utf8String,
            -1,
            nil
        )

        if sqlite3_step(updateStatement) != SQLITE_DONE {
            print("Could not update user.")
            print(String(cString: sqlite3_errmsg(db)))

            sqlite3_finalize(updateStatement)
            sqlite3_close(db)
            return false
        }

        let updatedRows = sqlite3_changes(db)

        sqlite3_finalize(updateStatement)
        sqlite3_close(db)

        if updatedRows == 0 {
            print("No user was found with username: \(currentUsername)")
            return false
        }

        print("User information updated successfully.")
        return true
    }
    
}
