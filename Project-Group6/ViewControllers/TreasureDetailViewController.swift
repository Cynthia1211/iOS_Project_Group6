//
//  TreasureDetailController.swift
//  Project_Group6
//
//  Created by Yue Zhang on on 2026-07-05.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth // To get user's uuid
import VisionKit // To enable scan function

// Author: Yue Zhang
// Description: View controller for inspecting a treasure, scanning codes, validating distance, and claiming reward points.
class TreasureDetailViewController: UIViewController, UITextFieldDelegate, DataScannerViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var smallMapView: MKMapView! // Small map preview UI component
    @IBOutlet weak var labelX: UILabel! // Label for latitude text
    @IBOutlet weak var labelY: UILabel! // Label for longitude text
    @IBOutlet weak var labelDescription: UILabel! // Label for title/description text
    @IBOutlet weak var labelMessage: UILabel! // Label for hint/message text
    @IBOutlet weak var txtTreasureCode: UITextField! // Text input for treasure code
    @IBOutlet weak var claimButton: UIButton! // Claim button
    @IBOutlet weak var scanButton: UIButton! // Camera scan button
    
    // Current Treasure object being viewed
    var treasure: Treasure?
    
    // Location manager to calculate user distance to treasure
    private let locationManager = CLLocationManager()
    
    // Location of user device
    private var currentLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegate to handle keyboard actions
        txtTreasureCode.delegate = self
        
        // Fill UI elements and small map view with treasure details
        setupUI()
        
        // Set location manager delegate to receive user coordinates
        locationManager.delegate = self
        
        // Request location permission from user
        locationManager.requestWhenInUseAuthorization()
        
        // Tracking device location for distance checking
        locationManager.startUpdatingLocation()
        
//        // Temp use for development
//        if let currentUser = Auth.auth().currentUser {
//            let uuid = currentUser.uid
//            
//            print("========================================")
//            print("Player UUID: \(uuid)")
//            print("========================================")
//            
//        } else {
//            print("⚠️ User is not login")
//        }
        
    }

    // Opens camera scanner view.
    // Checks hardware support and launches VisionKit scanner for text/barcodes.
    @IBAction func btnScanClicked(_ sender: UIButton) {
        
        // Avoid app crash if run on a simulator or device without camera support.
        guard DataScannerViewController.isSupported && DataScannerViewController.isAvailable else {
            let alert = UIAlertController(title: "Scan Unavailable", message: "Your device does not support camera scanning.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Initialize camera scanner to recognize QR codes and plain text
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [.qr]),
                .text()
            ],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighlightingEnabled: true
        )
        
        // Set scanner delegate and present camera view controller
        scanner.delegate = self
        present(scanner, animated: true) {
            try? scanner.startScanning()
        }
    }
    
    // Action for Claim / Found button.
    // Checks login, compares validation code, checks proximity, and updates database score.
    @IBAction func btnFoundItClicked(_ sender: UIButton) {
        
        // User must be logged in so points can be saved to their account.
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
        
        guard let treasure = treasure else { return }
        let userUUID = currentUser.uid
        
        guard let inputCode = txtTreasureCode.text, !inputCode.isEmpty else {
            let emptyAlert = UIAlertController(title: "Notice", message: "Scan or enter the code first!", preferredStyle: .alert)
            emptyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(emptyAlert, animated: true, completion: nil)
            return
        }
        
        // Remove extra spaces around input string to avoid false code mismatches
        if inputCode.trimmingCharacters(in: .whitespacesAndNewlines) == treasure.validationCode {
            
            // Check physical GPS location to ensure user is close enough to claim the treasure
            if !isUserNearTreasure() {
                let distanceAlert = UIAlertController(
                    title: "Too Far Away",
                    message: "You are too far from the treasure. Get closer!",
                    preferredStyle: .alert
                )
                distanceAlert.addAction(UIAlertAction(title: "OK", style: .default))
                present(distanceAlert, animated: true)
                return
                
            }
            
            // Update user score in the database
            let scoreUpdated = TreasureManager.shared.updateUserScore(userUUID: userUUID, additionalPoints: treasure.points)
            
            // Mark the current treasure as found in the database
            let treasureUpdated = TreasureManager.shared.markTreasureAsFound(treasureId: treasure.id, foundByUserId: userUUID)
            
            // Update local treasure object state
            treasure.isTreasureFound = true
            treasure.treasureFoundby = userUUID
            
            if scoreUpdated && treasureUpdated {
                print("Database updated successfully.")
            } else {
                print("Database update encountered an error.")
            }
            
            // Temp use for development
            // TreasureManager.shared.printRealDatabaseStatus(for: treasure.id, userUUID: userUUID)
            
            // Animation for successful claim
            showCongratulationEffect()
            
            // Create success dialog alert
            let successAlert = UIAlertController(
                title: "Congratulations! 🎉",
                message: "Success! You earned \(treasure.points) points!",
                preferredStyle: .alert
            )
            
            // Handle "Back to Map" action: navigate to Tab index 0
            successAlert.addAction(UIAlertAction(title: "Back to Map", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let tabBarController = self.tabBarController
                self.navigationController?.popToRootViewController(animated: false)
                tabBarController?.selectedIndex = 0
            }))
            
            // Handle "Check in My Treasures" action: navigate to Tab index 1
            successAlert.addAction(UIAlertAction(title: "Check in My Treasures", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let tabBarController = self.tabBarController
                self.navigationController?.popToRootViewController(animated: false)
                tabBarController?.selectedIndex = 1
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
    
    // Opens Apple Maps for navigation.
    // Passes coordinates to external Apple Maps app for turn-by-turn directions.
    @IBAction func btnNavigateClicked(_ sender: UIButton) {
        guard let treasure = treasure else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = treasure.title
        
        mapItem.openInMaps()
        
    }
    
    // Fills interface views with treasure values.
    // Assigns text labels and centers preview map pin on screen.
    private func setupUI() {
        guard let treasure = treasure else { return }
        
        // Get the details from treasure and show in labels
        title = treasure.title
        labelX.text = "X: \(treasure.latitude)"
        labelY.text = "Y: \(treasure.longitude)"
        labelDescription.text = "\(treasure.title)"
        labelMessage.text = "\(treasure.treasureMessage)"
        
        // Center small preview map around the treasure location of 100m x 100m area
        let coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        smallMapView.setRegion(region, animated: false)
        
        // Add a marker pin at treasure coordinates on the small map
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = treasure.title
        smallMapView.addAnnotation(annotation)
    }
    
    // VisionKit delegate method when camera scans code.
    // Receives text from camera, populates input box, and automatically triggers claim button.
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        var scannedCode: String?
        
        // Parse code from scanned result based on item type
        switch item {
        case .text(let text):
            scannedCode = text.transcript
        case .barcode(let barcode):
            scannedCode = barcode.payloadStringValue
        @unknown default:
            break
        }
        
        if let code = scannedCode {
            
            // Dismiss camera controller before opening success dialog to prevent UI overlaps.
            dataScanner.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                // Fill text field with scanned code
                self.txtTreasureCode.text = code
                
                // Automatically trigger the claim button event
                self.btnFoundItClicked(self.claimButton)
                
            }
        }
        
    }
    
    // Update user's current GPS location whenever location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.last {
            self.currentLocation = location
        }
    }
    
    // Handle errors when location manager fails to retrieve GPS data
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    // Check if user is near the treasure
    // Calculate distance between user and treasure < 30m
    private func isUserNearTreasure() -> Bool {
        guard let currentLocation = currentLocation, let treasure = treasure else {
            return false
        }
        
        let treasureLocation = CLLocation(latitude: treasure.latitude, longitude: treasure.longitude)
        let distanceInMeters = currentLocation.distance(from: treasureLocation)
        
        print("Distance: \(distanceInMeters)")
        
        return distanceInMeters <= 30.0
    }
    
    // Play animation when treasure is successfully claimed
    private func showCongratulationEffect() {
        
        guard let confettiImage = UIImage(named: "congratulation") else { return }
        
        // Get screen dimensions and calculate proportional height to maintain image aspect ratio
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        let imageRatio = confettiImage.size.height / confettiImage.size.width
        let imageHeight = screenWidth * imageRatio
        
        // Create image view and configure aspect ratio mode
        let confettiImageView = UIImageView(image: confettiImage)
        confettiImageView.contentMode = .scaleAspectFit
        
        // Position image view above the visible screen boundary (off-screen top)
        confettiImageView.frame = CGRect(x: 0, y: -imageHeight, width: screenWidth, height: imageHeight)
        confettiImageView.alpha = 1.0
        
        // Add image view to the main container
        view.addSubview(confettiImageView)
        
        // Calculate vertical center position on screen for destination target
        let targetY = (screenHeight - imageHeight) / 2.0
        
        // 4-second animation: move downward to screen center while fading out to transparent
        UIView.animate( withDuration: 4.0, delay: 0,
            animations: {
                confettiImageView.frame.origin.y = targetY
                confettiImageView.alpha = 0.0
            },
            completion: { _ in
                confettiImageView.removeFromSuperview()
            }
        )
    }
    
    // Hide keyboard when user presses 'Return' on text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
