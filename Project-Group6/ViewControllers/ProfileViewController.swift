//
//  ProfileController.swift
//  Project_Group6
//
//  Created by 
//

import UIKit
import WebKit

/**
 Principal Author: Cena Nguyen
 
 Description:
 This view controller displays the current user's profile information.
 It retrieves stored user data and presents the username, email,
 and date of birth on the profile screen.
 */
class ProfileViewController:
    UIViewController, WKNavigationDelegate {
    
    let profileManager = ProfileManager()
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var lblDOB: UILabel!
    @IBOutlet var tfUsername: UITextField!
    @IBOutlet var tfEmail: UITextField!
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activity.isHidden = false
        activity.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    func validateUsername(username: String) -> Bool {
        
        let foundUser = profileManager.getUser(username: username)
        
        if foundUser != nil {
            let alert = UIAlertController(title: "Error", message: "The username you selected already exists", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
            return false
        }
        
        return true
    }
    
    @IBAction func updateInfo(_ sender: UIButton) {

        let newUsername = tfUsername.text ?? ""
        let newEmail = tfEmail.text ?? ""
        
        // if user did not update their info
        if newUsername == mainDelegate.currentUsername && newEmail == mainDelegate.currentEmail {
            let alert = UIAlertController(title: "Error", message: "Please enter your updated info", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }

        guard !newUsername.isEmpty, !newEmail.isEmpty else {
            return
        }

        guard validateUsername(username: newUsername) else {
            return
        }

        let alert = UIAlertController(
            title: "Update Information",
            message: "Are you sure you want to update your username and email?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: "Update",
            style: .default
        ) { _ in

            let wasUpdated = self.profileManager.updateUserInfo(
                currentUsername: self.mainDelegate.currentUsername,
                newUsername: newUsername,
                newEmail: newEmail
            )

            if wasUpdated {
                self.mainDelegate.currentUsername = newUsername
                self.mainDelegate.currentEmail = newEmail

                // Reload the people array from SQLite
                self.mainDelegate.readDataFromDatabase()

                print("Current user updated to \(newUsername)")
                
                // Reload profile
                self.loadProfile()
            }
        })

        present(alert, animated: true)
    }
    
    private func loadProfile() {
        if let currentUser = profileManager.getUser(username: mainDelegate.currentUsername) {

            tfUsername.text = currentUser.username
            tfEmail.text = currentUser.email
            tfUsername.placeholder = currentUser.username
            tfEmail.placeholder = currentUser.email
            lblDOB.text = currentUser.dateofBirth
        }
    }
    
    /**
     Loads the user's profile information when the screen appears.
     
     The information is retrieved from AppDelegate because the user
     has already created an account and their information is temporarily
     stored for profile display.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        
        webView.navigationDelegate = self
        let urlAddress = URL(string: "https://www.geocaching.com/play")
        let url = URLRequest(url: urlAddress!)
        webView.load(url)
    }
}
