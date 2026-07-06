//
//  MapController.swift
//  Project_Group6
//
//  Created by Yue Zhang on 2026-07-05.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var treasuresArray = [Treasure]()

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        if sender.value != roundedValue {
            sender.setValue(roundedValue, animated: false)
        }
            
        updateDistanceLabel()

        filterTreasures()
        
        if let currentCoord = currentUserCoordinate {
            let maxDistance = getCurrentRadiusInMeters()
            let region = MKCoordinateRegion(center: currentCoord, latitudinalMeters: maxDistance * 1.1, longitudinalMeters: maxDistance * 1.1)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCurrentRadiusInMeters() -> Double {
        let sliderValue = round(distanceSlider.value)
        if sliderValue == 1 {
            return 50.0         // 50m
        } else if sliderValue == 2 {
            return 200.0        // 200m
        } else if sliderValue == 3 {
            return 1000.0       // 1km
        } else if sliderValue == 4 {
            return 5000.0       // 5km
        } else if sliderValue == 5 {
            return 10000.0      // 10km
        } else {
            return 100000.0     // 10+ km
        }
    }
    
    @IBOutlet weak var distanceLabel: UILabel!
    private func updateDistanceLabel() {
        let sliderValue = round(distanceSlider.value)
        if sliderValue == 1 {
            distanceLabel.text = "Showing treasures around within 50m"
        } else if sliderValue == 2 {
            distanceLabel.text = "Showing treasures around within 200m"
        } else if sliderValue == 3 {
            distanceLabel.text = "Showing treasures around within 1 km"
        } else if sliderValue == 4 {
            distanceLabel.text = "Showing treasures around within 5 km"
        } else if sliderValue == 5 {
            distanceLabel.text = "Showing treasures around within 10 km"
        } else {
            distanceLabel.text = "Showing treasures around within 10+ km" 
        }
    }
    
    
    let locationManager = CLLocationManager()
    var currentUserCoordinate: CLLocationCoordinate2D?
    var isFirstLocationUpdate = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temp use
        self.treasuresArray = MockData.treasures

        mapView.delegate = self
        setupLocationManager()
        updateDistanceLabel()
        
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
                
            currentUserCoordinate = location.coordinate
                
            if isFirstLocationUpdate {
                let currentRadius = getCurrentRadiusInMeters()
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: currentRadius * 2, longitudinalMeters: currentRadius * 2)
                mapView.setRegion(region, animated: true)
                
                isFirstLocationUpdate = false
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
            
        let centerLocation = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
        let maxDistance = getCurrentRadiusInMeters()
            
        // Using MockData.
        for treasure in treasuresArray {
            
            if treasure.isTreasureFound {
                continue 
            }
            
            let treasureLocation = CLLocation(latitude: treasure.latitude, longitude: treasure.longitude)
            let distanceInMeters = centerLocation.distance(from: treasureLocation)
                
            if distanceInMeters <= maxDistance {
                let annotation = TreasureAnnotation(treasure: treasure)
                mapView.addAnnotation(annotation)
            }
        }
            
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
