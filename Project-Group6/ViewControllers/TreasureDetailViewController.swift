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

class TreasureDetailViewController: UIViewController, UITextFieldDelegate, DataScannerViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var smallMapView: MKMapView!
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var txtTreasureCode: UITextField!
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    
    
    var treasure: Treasure?
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtTreasureCode.delegate = self
        
        setupUI()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let currentUser = Auth.auth().currentUser {
            let uuid = currentUser.uid
            
            print("========================================")
            print("Player UUID: \(uuid)")
            print("========================================")
            
        } else {
            print("⚠️ User is not login")
        }
        
    }
    

    @IBAction func btnScanClicked(_ sender: UIButton) {
        
        guard DataScannerViewController.isSupported && DataScannerViewController.isAvailable else {
            let alert = UIAlertController(title: "Scan Unavailable", message: "Your device does not support camera scanning.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [.qr]),
                .text()
            ],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = self
        present(scanner, animated: true) {
            try? scanner.startScanning()
        }
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
        
        
        guard let treasure = treasure else { return }
        
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
        
        let userUUID = currentUser.uid
        
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
            
            TreasureManager.shared.printRealDatabaseStatus(for: treasure.id, userUUID: userUUID)
            
            showConfettiImageEffect()
            
            let successAlert = UIAlertController(
                title: "Congratulations! 🎉",
                message: "Success! You earned \(treasure.points) points!",
                preferredStyle: .alert
            )
            
            successAlert.addAction(UIAlertAction(title: "Back to Map", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let tabBarController = self.tabBarController
                self.navigationController?.popToRootViewController(animated: false)
                tabBarController?.selectedIndex = 0
            }))
            
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
    
    @IBAction func btnNavigateClicked(_ sender: UIButton) {
        guard let treasure = treasure else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = treasure.title
        
        mapItem.openInMaps()
        
    }
    
    private func setupUI() {
        guard let treasure = treasure else { return }
        
        title = treasure.title
        labelX.text = "X: \(treasure.latitude)"
        labelY.text = "Y: \(treasure.longitude)"
        labelDescription.text = "\(treasure.title)"
        labelMessage.text = "\(treasure.treasureMessage)"
        
        
        let coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        smallMapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = treasure.title
        smallMapView.addAnnotation(annotation)
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        var scannedCode: String?
        
        switch item {
        case .text(let text):
            scannedCode = text.transcript
        case .barcode(let barcode):
            scannedCode = barcode.payloadStringValue
        @unknown default:
            break
        }
        
        if let code = scannedCode {
            
            dataScanner.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                self.txtTreasureCode.text = code
                
                self.btnFoundItClicked(self.claimButton)
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.last {
            self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    private func isUserNearTreasure() -> Bool {
        guard let currentLocation = currentLocation, let treasure = treasure else {
            return false
        }
        
        let treasureLocation = CLLocation(latitude: treasure.latitude, longitude: treasure.longitude)
        let distanceInMeters = currentLocation.distance(from: treasureLocation)
        
        print("Distance: \(distanceInMeters)")
        
        return distanceInMeters <= 30.0
    }
    
    
    private func showConfettiImageEffect() {
        
        guard let confettiImage = UIImage(named: "congratulation") else { return }
        
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        let imageRatio = confettiImage.size.height / confettiImage.size.width
        let imageHeight = screenWidth * imageRatio
        
        
        let confettiImageView = UIImageView(image: confettiImage)
        confettiImageView.contentMode = .scaleAspectFit
        
        confettiImageView.frame = CGRect(x: 0, y: -imageHeight, width: screenWidth, height: imageHeight)
        confettiImageView.alpha = 1.0
        
        view.addSubview(confettiImageView)
        
        UIView.animate(
            withDuration: 2.8,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {

                confettiImageView.frame.origin.y = screenHeight
            },
            completion: { _ in

                confettiImageView.removeFromSuperview()
            }
        )
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
