//
//  NewTreasureViewController.swift
//  Project-Group6
//
//  Created by Alexander Tumanan on 2026-08-01.
//

import UIKit
import MapKit
import CoreLocation

// Author: Alexander Tumanan
// Description: Lets the user tap a location on the map and place a new
// treasure there.
class NewTreasureViewController: UIViewController, CLLocationManagerDelegate {

    let mainDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblX: UILabel!  // Displays the selected latitude
    @IBOutlet weak var lblY: UILabel!  // Displays the selected longitude
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var zoomSlider: UISlider!  // Controls how zoomed in the map is

    // The coordinate the user selected on the map. Nil until they tap.
    var selectedCoordinate: CLLocationCoordinate2D?

    // Location manager instance to get device GPS updates
    let locationManager = CLLocationManager()

    // The device's current location, once found. The map centers on
    // this until the user taps a different spot.
    var currentUserCoordinate: CLLocationCoordinate2D?

    // Looks up the UUID of the currently logged-in user by matching
    // their email against the people array.
    var currentUserUUID: String {
        mainDelegate.people
            .first(where: { $0.email?.lowercased() == mainDelegate.currentEmail.lowercased() })?
            .uuid ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Detects taps on the map so a location can be selected.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)

        lblX.text = "X: "
        lblY.text = "Y: "

        // Start at a moderate zoom level regardless of the slider's
        // default value in the storyboard.
        zoomSlider.value = 1.0

        // Shows the blue dot for the device's location on the map.
        mapView.showsUserLocation = true

        // Configure location manager settings and request GPS permissions
        setupLocationManager()
    }

    // Setup and start location service updates
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Delegate method called whenever user location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Only need the initial fix to center the map, so ignore
            // further updates once we already have a coordinate.
            if currentUserCoordinate == nil {
                currentUserCoordinate = location.coordinate
                updateMapZoom()
                locationManager.stopUpdatingLocation()
            }
        }
    }

    // Delegate method called when location updates fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }

    // Called when the zoom slider moves. Smaller values zoom in closer,
    // larger values zoom out further.
    @IBAction func zoomSliderChanged(_ sender: UISlider) {
        updateMapZoom()
    }

    // Applies the slider's current value as the map's zoom span,
    // centered on the device's current location (or the map's current
    // center if the location hasn't been found yet).
    func updateMapZoom() {
        let center = currentUserCoordinate ?? mapView.centerCoordinate
        let span = MKCoordinateSpan(
            latitudeDelta: Double(zoomSlider.value),
            longitudeDelta: Double(zoomSlider.value)
        )
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }

    // Called when the user taps the map. Drops a pin at the tapped
    // location and updates the X/Y labels with the coordinates.
    @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

        selectedCoordinate = coordinate

        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)

        lblX.text = String(format: "X: %.2f", coordinate.latitude)
        lblY.text = String(format: "Y: %.2f", coordinate.longitude)
    }

    // Called when the Place button is tapped. Validates the input and
    // saves the new treasure to the database.
    @IBAction func placeButtonTapped(_ sender: UIButton) {
        // A location must be selected before placing a treasure.
        guard let coordinate = selectedCoordinate else {
            showAlert(title: "No Location Selected", message: "Tap a spot on the map to choose where to place your treasure.")
            return
        }

        // A description is required.
        guard let description = descriptionField.text, !description.isEmpty else {
            showAlert(title: "Missing Description", message: "Please enter a description for your treasure.")
            return
        }

        let message = messageField.text ?? ""

        // Generates a short code the finder will need to claim the treasure.
        let validationCode = String(UUID().uuidString.prefix(6)).uppercased()

        let newTreasure = Treasure(
            title: description,
            treasureMessage: message,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            validationCode: validationCode,
            treasurePlaceBy: currentUserUUID
        )

        let success = TreasureManager.shared.addNewTreasure(treasure: newTreasure)

        if success {
            let alert = UIAlertController(
                title: "Treasure Placed!",
                message: "Your treasure's code is \(validationCode). Share it with whoever finds it.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            showAlert(title: "Error", message: "Something went wrong saving your treasure. Please try again.")
        }
    }

    // Displays a simple one-button alert with the given title and message.
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
