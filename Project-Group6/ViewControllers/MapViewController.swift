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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var treasuresArray = [Treasure]()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        isUserInteracting = false
        
        let roundedValue = round(sender.value)
        if sender.value != roundedValue {
            sender.setValue(roundedValue, animated: false)
        }
            
        updateDistanceLabel()

        filterTreasures()
        
        if let currentCoord = currentUserCoordinate {
            let maxDistance = getCurrentRadiusInMeters()
            let region = MKCoordinateRegion(center: currentCoord, latitudinalMeters: maxDistance * 1.05, longitudinalMeters: maxDistance * 1)
            mapView.setRegion(region, animated: true)
        }
    }
    
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
    
    @IBOutlet weak var distanceLabel: UILabel!
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
    
    
    let locationManager = CLLocationManager()
    var currentUserCoordinate: CLLocationCoordinate2D?
    var isUserInteracting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        setupLocationManager()
        updateDistanceLabel()
        
        if let currentUser = Auth.auth().currentUser {
            let uuid = currentUser.uid
            
            print("========================================")
            print("MapViewController")
            print("Player UUID: \(uuid)")
            print("========================================")
                        
        } else {
            print("⚠️ User is not login")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterTreasures()
    }
    
    private func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
           // print("User Location Is Updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            if let oldCoord = currentUserCoordinate {
                let oldLocation = CLLocation(latitude: oldCoord.latitude, longitude: oldCoord.longitude)
                if location.distance(from: oldLocation) < 10 {
                    return
                }
            }
                
            currentUserCoordinate = location.coordinate
                
            if !isUserInteracting {
                let currentRadius = getCurrentRadiusInMeters()
                        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: currentRadius * 1.05, longitudinalMeters: currentRadius * 1)
                        mapView.setRegion(region, animated: true)
            }
            
                
            filterTreasures()
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
    

    private func filterTreasures() {
        guard let currentCoord = currentUserCoordinate else {
            print("No User Location")
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        let currentHalfSideLength = getCurrentRadiusInMeters()
        
        self.treasuresArray = TreasureManager.shared.fetchTreasuresAround(
            centerLat: currentCoord.latitude, centerLon: currentCoord.longitude, halfSideLengthInMeters: currentHalfSideLength )
        
        let annotations = self.treasuresArray.map { TreasureAnnotation(treasure: $0) }
        mapView.addAnnotations(annotations)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
            
        let reuseId = "TreasurePin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
            
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
            
        if let treasureAnnotation = annotation as? TreasureAnnotation {
            pinView?.markerTintColor = treasureAnnotation.treasure.isTreasureFound ? .systemGray : .systemRed
        }
        return pinView
    }

    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if let view = mapView.subviews.first, let gestureRecognizers = view.gestureRecognizers {
            for gesture in gestureRecognizers {
                if gesture.state == .began || gesture.state == .changed {

                    isUserInteracting = true
                    
                    break
                }
            }
        }
    }
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let treasureAnnotation = view.annotation as? TreasureAnnotation {
                performSegue(withIdentifier: "goToTreasureDetail", sender: treasureAnnotation.treasure)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTreasureDetail",
            let detailVC = segue.destination as? TreasureDetailViewController,
            let selectedTreasure = sender as? Treasure {
            detailVC.treasure = selectedTreasure
        }
    }

}
