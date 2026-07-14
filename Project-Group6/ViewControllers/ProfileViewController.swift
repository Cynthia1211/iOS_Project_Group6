//
//  ProfileController.swift
//  Project_Group6
//
//  Created by 
//

import UIKit
/**
 Principal Author: Cena Nguyen
 
 Description:
 This view controller displays the current user's profile information.
 It retrieves stored user data and presents the username, email,
 and date of birth on the profile screen.
 */
class ProfileViewController:
    UIViewController {
    // Handles retrieving profile information.
       let profileManager = ProfileManager()
    // Displays the current user's username.
    @IBOutlet var usenameLabel: UILabel!
    // Displays the current user's email address.
    @IBOutlet var emailLabel: UILabel!
    // Displays the current user's date of birth.
    @IBOutlet var dateodBirthLabel: UILabel!
    
    
    
    /**
         Loads the user's profile information when the screen appears.
         
         The information is retrieved from AppDelegate because the user
         has already created an account and their information is temporarily
         stored for profile display.
         */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Retrieve the user's saved profile information.
               if let user = profileManager.getCurrentUser() {
                   
                   
                   // Update labels with formatted profile information.
                   usenameLabel.text =
                   "Welcome: \(user.username ?? "")"
                   
                   
                   dateodBirthLabel.text =
                   "Date Of Birth: \(user.dateofBirth ?? "")"
                   
                   
                   emailLabel.text =
                   "Email: \(user.email ?? "")"
               }
           }
       }
