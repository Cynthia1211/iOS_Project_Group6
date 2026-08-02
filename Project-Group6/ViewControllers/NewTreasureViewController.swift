//
//  NewTreasureViewController.swift
//  Project-Group6
//
//  Created by Alexander Tumanan on 2026-08-01.
// Description: "Place New Treasure" screen. User taps a spot on the map
// to choose a location, fills in a description and a message, then taps
// Place to save the new treasure to the database.

import UIKit
import MapKit

class NewTreasureViewController: UIViewController {

    let mainDelegate = UIApplication.shared.delegate as! AppDelegate

    var currentUserUUID: String {
        mainDelegate.people
            .first(where: { $0.email?.lowercased() == mainDelegate.currentEmail.lowercased() })?
            .uuid ?? ""
    }

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var lblX: UILabel!
    @IBOutlet var lblY: UILabel!
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var messageField: UITextField!

    // Coordinate the user picked by tapping the map. Nil until they tap.
    var selectedCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)

        lblX.text = "X: "
        lblY.text = "Y: "
    }

    // Drops a pin at the tapped location and updates the X/Y labels.
    @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

        selectedCoordinate = coordinate

        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)

        lblX.text = String(format: "X: %.5f", coordinate.latitude)
        lblY.text = String(format: "Y: %.5f", coordinate.longitude)
    }

    @IBAction func placeButtonTapped(_ sender: UIButton) {
        guard let coordinate = selectedCoordinate else {
            showAlert(title: "No Location Selected", message: "Tap a spot on the map to choose where to place your treasure.")
            return
        }

        guard let description = descriptionField.text, !description.isEmpty else {
            showAlert(title: "Missing Description", message: "Please enter a description for your treasure.")
            return
        }

        let message = messageField.text ?? ""
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

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
