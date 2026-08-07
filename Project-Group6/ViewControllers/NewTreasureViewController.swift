//
//  NewTreasureViewController.swift
//  Project-Group6
//
//  Created by Alexander Tumanan on 2026-08-01.
//

import UIKit
import MapKit

// Lets the user tap a location on the map and place a new treasure there.
class NewTreasureViewController: UIViewController {

    let mainDelegate = UIApplication.shared.delegate as! AppDelegate

    // Looks up the UUID of the currently logged-in user by matching
    // their email against the people array.
    var currentUserUUID: String {
        mainDelegate.people
            .first(where: { $0.email?.lowercased() == mainDelegate.currentEmail.lowercased() })?
            .uuid ?? ""
    }

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var lblX: UILabel!  // Displays the selected latitude
    @IBOutlet var lblY: UILabel!  // Displays the selected longitude
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var messageField: UITextField!

    // The coordinate the user selected on the map. Nil until they tap.
    var selectedCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Detects taps on the map so a location can be selected.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)

        lblX.text = "X: "
        lblY.text = "Y: "
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

        lblX.text = String(format: "X: %.5f", coordinate.latitude)
        lblY.text = String(format: "Y: %.5f", coordinate.longitude)
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
