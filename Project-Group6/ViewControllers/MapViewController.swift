//
//  MapController.swift
//  Project_Group6
//
//  Created by Yue Zhang on 2026-07-05.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth

// Author: Yue Zhang
// Description: View controller for displaying the map, user position, and nearby treasure pins.
class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Array storing nearby treasures
    var treasuresArray = [Treasure]()

    @IBOutlet weak var mapView: MKMapView! // Map viewoutlet
    @IBOutlet weak var distanceSlider: UISlider! // Distance slider outlet
    
    // Handles slider value changes to update distance label, filter nearby treasures, and adjust map region
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        // Disable automatic map re-centering while user is dragging the slider
        isUserInteracting = false
        
        // Round the slider value to the nearest integer
        let roundedValue = round(sender.value)
        if sender.value != roundedValue {
            sender.setValue(roundedValue, animated: false)
        }
            
        // Update label text based on current slider distance
        updateDistanceLabel()

        // Fetch and show treasures matching the new distance
        filterTreasures()
        
        // Update visible region on map view centered at user location
        if let currentCoord = currentUserCoordinate {
            let maxDistance = getCurrentRadiusInMeters()
            let region = MKCoordinateRegion(center: currentCoord, latitudinalMeters: maxDistance * 1.05, longitudinalMeters: maxDistance * 1)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Get search range from slider
    private func getCurrentRadiusInMeters() -> Double {
        let sliderValue = round(distanceSlider.value)
        if sliderValue == 1 {
            return 500.0        // 500m
        } else if sliderValue == 2 {
            return 1000.0       // 1km
        } else if sliderValue == 3 {
            return 5000.0       // 5km
        } else if sliderValue == 4 {
            return 10000.0      // 10km
        } else {
            return 100000.0     // 100 km
        }
    }
    
    // Display the distance range we are showing
    @IBOutlet weak var distanceLabel: UILabel!
    
    // Update the distance label when sliderValue is changed
    private func updateDistanceLabel() {
        let sliderValue = round(distanceSlider.value)
        if sliderValue == 1 {
            distanceLabel.text = "Showing treasures around you in 500m"
        } else if sliderValue == 2 {
            distanceLabel.text = "Showing treasures around you in 1km"
        } else if sliderValue == 3 {
            distanceLabel.text = "Showing treasures around you in 5km"
        } else if sliderValue == 4 {
            distanceLabel.text = "Showing treasures around you in 10km"
        } else {
            distanceLabel.text = "Showing treasures around you  in 100km"
        }
    }
    
    // Location manager instance to get device GPS updates
    let locationManager = CLLocationManager()
    var currentUserCoordinate: CLLocationCoordinate2D?
    
    // Flag to indicate if user is manually touching or panning the map
    var isUserInteracting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        // Configure location manager settings and request GPS permissions
        setupLocationManager()
        
        // Set initial text for distance label on load
        updateDistanceLabel()
        
//        // Temp use for development
//        if let currentUser = Auth.auth().currentUser {
//            let uuid = currentUser.uid
//            
//            print("========================================")
//            print("MapViewController")
//            print("Player UUID: \(uuid)")
//            print("========================================")
//                        
//        } else {
//            print("⚠️ User is not login")
//        }
        
    }
    
    // Refresh the available treasures in map when back to this page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterTreasures()
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
           // print("User Location Is Updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Avoid refreshing by GPS jitter
            if let oldCoord = currentUserCoordinate {
                let oldLocation = CLLocation(latitude: oldCoord.latitude, longitude: oldCoord.longitude)
                if location.distance(from: oldLocation) < 10 {
                    return
                }
            }
                
            currentUserCoordinate = location.coordinate
                
            // If user is not manually interacting with the map, update map region to stay centered on user
            if !isUserInteracting {
                let currentRadius = getCurrentRadiusInMeters()
                        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: currentRadius * 1.05, longitudinalMeters: currentRadius * 1)
                        mapView.setRegion(region, animated: true)
            }
                
            filterTreasures()
        }
    }
        
    // Delegate method called when location updates fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
    
    // Fetch treasures within selected distance and display them as pins on map
    private func filterTreasures() {
        guard let currentCoord = currentUserCoordinate else {
            print("No User Location")
            return
        }
        
        // Clear all existing pins from map before updating
        mapView.removeAnnotations(mapView.annotations)
        
        // Get current search radius in meters
        let currentHalfSideLength = getCurrentRadiusInMeters()
        
        // Read nearby active treasures from local database
        self.treasuresArray = TreasureManager.shared.fetchTreasuresAround(
            centerLat: currentCoord.latitude, centerLon: currentCoord.longitude, halfSideLengthInMeters: currentHalfSideLength )
        
        // Convert treasure models into map annotations and add to map view
        let annotations = self.treasuresArray.map { TreasureAnnotation(treasure: $0) }
        mapView.addAnnotations(annotations)
        
    }
    
    // Customize annotation pin views and colors based on treasure status
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
            
        // Identifier for reusable map pin views
        let reuseId = "TreasurePin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
            
        // Create new pin view if no reusable view is available
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
            
        // Set pins to red
        pinView?.markerTintColor = .systemRed
        
        return pinView
    }

    // Detect user dragging or zooming gestures on map view
    // Checks if any gesture recognizer on the map's subview is active (.began or .changed).
    // This distinguishes user manual touch/drag from programmatic map updates (like setRegion).
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        // Get the map view's underlying view and its gesture recognizers
        if let view = mapView.subviews.first, let gestureRecognizers = view.gestureRecognizers {
            
            // Loop through all attached gesture recognizers
            for gesture in gestureRecognizers {
                
                // Check if user is actively touching, dragging, or zooming the map
                if gesture.state == .began || gesture.state == .changed {

                    isUserInteracting = true
                    
                    break
                }
            }
        }
    }
        
    // Handle tap event on pin shows detail button
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let treasureAnnotation = view.annotation as? TreasureAnnotation {
                performSegue(withIdentifier: "goToTreasureDetail", sender: treasureAnnotation.treasure)
        }
    }
    
    // Pass selected treasure object to TreasureDetailViewController during segue transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTreasureDetail",
            let detailVC = segue.destination as? TreasureDetailViewController,
            let selectedTreasure = sender as? Treasure {
            detailVC.treasure = selectedTreasure
        }
    }

}
