//
//  TreasureDetailController.swift
//  Project_Group6
//
//  Created by Yue Zhang on on 2026-07-05.
//

import UIKit
import MapKit
import FirebaseAuth

class TreasureDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var smallMapView: MKMapView!
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var txtTreasureCode: UITextField!
    @IBOutlet weak var claimButton: UIButton!
    
    var treasure: Treasure?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtTreasureCode.delegate = self
        
        setupUI()
        
        
        if let currentUser = Auth.auth().currentUser {
            let uuid = currentUser.uid
                        
            print("========================================")
            print("Player UUID: \(uuid)")
            print("========================================")
                        
        } else {
            print("⚠️ User is not login")
        }
        
    }
    
    private func setupUI() {
        guard let treasure = treasure else { return }

        title = treasure.title
        labelX.text = "X: \(treasure.latitude)"
        labelY.text = "Y: \(treasure.longitude)"
        labelDescription.text = "Description: \(treasure.title)"
        labelMessage.text = "Messages: \(treasure.treasureMessage)"
        

        let coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        smallMapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = treasure.title
        smallMapView.addAnnotation(annotation)
    }


    @IBAction func btnFoundItClicked(_ sender: UIButton) {
        
        guard let currentUser = Auth.auth().currentUser else {
            let loginAlert = UIAlertController(
                title: "Login Required",
                message: "You must be logged in to continue!",
                preferredStyle: .alert
            )
            
            loginAlert.addAction(UIAlertAction(title: "Go to Login", style: .default, handler: { _ in
                if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = loginVC
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                    }
                }
            }))
            
            loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(loginAlert, animated: true, completion: nil)
            return
        }
        
        let userUUID = currentUser.uid
        
        guard let treasure = treasure else { return }
        
        guard let inputCode = txtTreasureCode.text, !inputCode.isEmpty else {
            let emptyAlert = UIAlertController(title: "Notice", message: "Scan or enter the code first!", preferredStyle: .alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(emptyAlert, animated: true, completion: nil)
            return
        }
        
        if inputCode.trimmingCharacters(in: .whitespacesAndNewlines) == treasure.validationCode {
            
            let scoreUpdated = TreasureManager.shared.updateUserScore(userUUID: userUUID, additionalPoints: treasure.points)

            let treasureUpdated = TreasureManager.shared.markTreasureAsFound(treasureId: treasure.id, foundByUserId: userUUID)
            
            treasure.isTreasureFound = true
            treasure.treasureFoundby = userUUID
            
            if scoreUpdated && treasureUpdated {
                print("Database updated successfully.")
            } else {
                print("Database update encountered an error.")
            }
            
            // Temp use
            TreasureManager.shared.printRealDatabaseStatus(for: treasure.id, userUUID: userUUID)
            
            let successAlert = UIAlertController(
                title: "Congratulations! 🎉",
                message: "Success! You earned \(treasure.points) points!",
                preferredStyle: .alert
            )
            
            successAlert.addAction(UIAlertAction(title: "Awesome", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(successAlert, animated: true, completion: nil)
            
        } else {
            let errorAlert = UIAlertController(
                title: "Invalid Code",
                message: "The treasure code you entered is incorrect. Please try again!",
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
            
        }
    
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
