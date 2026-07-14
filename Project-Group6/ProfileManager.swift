//
//  ProfileManager.swift
//  Project_Group6
//
//  Created by Cena Nguyen on 2026-07-14.
//

import Foundation
import UIKit

/**
 Principal Author: Cena Nguyen

 Description:
 This class manages retrieving and storing user profile information.
 It separates profile data logic from ProfileViewController
 to keep the view controller responsible only for UI updates.
 */
class ProfileManager {
    
    
    // Accesses the shared AppDelegate where SQLite data is stored.
    private let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    /**
     Retrieves the current user's profile information.
     
     This method reads data from SQLite and returns the latest
     saved user information.
     
     - Returns:
       A PeopleData object containing username, date of birth,
       and email. Returns nil if no user exists.
     */
    func getCurrentUser() -> PeopleData? {
        
        // Refresh database information before retrieving data.
        mainDelegate.readDataFromDatabase()
        
        
        // Return the most recently added user.
        return mainDelegate.people.last
    }
}
