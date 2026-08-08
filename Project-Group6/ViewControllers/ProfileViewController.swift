//
//  ProfileController.swift
//  Project_Group6
//
//  Created by Sophie School on 2026-07-30.
//

import UIKit
import WebKit

// Manages profile information and displays the Geocaching website.
class ProfileViewController:
    UIViewController, WKNavigationDelegate {
    
    let profileManager = ProfileManager()
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var lblDOB: UILabel!
    @IBOutlet var tfUsername: UITextField!
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    // Displays the activity indicator when the web page begins loading.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activity.isHidden = false
        activity.startAnimating()
    }
    
    // Hides the activity indicator after the web page finishes loading.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    // Verifies that the selected username is not already in use.
    // Returns true when the username is available; otherwise, false.
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
    
    // Validates and saves the user's updated username.
    @IBAction func updateInfo(_ sender: UIButton) {

        // Retrieve the updated username from the user interface.
        let newUsername = tfUsername.text ?? ""
        
        // if user did not update their info
        if newUsername == mainDelegate.currentUsername {
            let alert = UIAlertController(title: "Error", message: "Please enter your updated info", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
            return
        }

        // if info entered is empty
        if newUsername.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Input cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
            return
        }

        // validate username does not already exist
        guard validateUsername(username: newUsername) else {
            return
        }

        let alert = UIAlertController(
            title: "Update Username",
            message: "Are you sure you want to update your username?",
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
                newUsername: newUsername
            )

            if wasUpdated {
                // Synchronize the application's current user with the database.
                self.mainDelegate.currentUsername = newUsername

                self.mainDelegate.readDataFromDatabase()

                print("Current user updated to \(newUsername)")
                
                self.loadProfile()
            }
        })

        present(alert, animated: true)
    }
    
    // Loads the current user's profile information into the interface.
    private func loadProfile() {
        if let currentUser = profileManager.getUser(username: mainDelegate.currentUsername) {

            tfUsername.text = currentUser.username
            lblDOB.text = currentUser.dateofBirth
        }
    }
    
    // Loads the profile data and configures the embedded web view.
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        
        webView.navigationDelegate = self
        let urlAddress = URL(string: "https://www.geocaching.com/play")
        let url = URLRequest(url: urlAddress!)
        webView.load(url)
    }
}
