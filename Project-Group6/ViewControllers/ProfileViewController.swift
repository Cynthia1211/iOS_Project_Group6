//
//  ProfileController.swift
//  Project_Group6
//
//  Created by Sophie School on 2026-07-30.
//

import UIKit
import WebKit

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

        // if info entered is empty
        if newUsername.isEmpty || !newEmail.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Input cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }

        // validate username does not already exist
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

                self.mainDelegate.readDataFromDatabase()

                print("Current user updated to \(newUsername)")
                
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        
        webView.navigationDelegate = self
        let urlAddress = URL(string: "https://www.geocaching.com/play")
        let url = URLRequest(url: urlAddress!)
        webView.load(url)
    }
}
