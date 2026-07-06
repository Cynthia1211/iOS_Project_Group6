//
//  TreasureDetailController.swift
//  Project_Group6
//
//  Created by Yue Zhang on on 2026-07-05.
//

import UIKit
import MapKit

class TreasureDetailViewController: UIViewController {

    @IBOutlet weak var smallMapView: MKMapView!
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var txtTreasureCode: UITextField!
    
    // 接收从地图页面传过来的宝藏数据
    var treasure: Treasure?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let treasure = treasure else { return }
        

        title = treasure.title
        labelX.text = "X: \(treasure.latitude)"
        labelY.text = "Y: \(treasure.longitude)"
        labelDescription.text = "Description: \(treasure.treasureDescription)"
        labelMessage.text = "Messages: Status pending..."
        

        let coordinate = CLLocationCoordinate2D(latitude: treasure.latitude, longitude: treasure.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        smallMapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = treasure.title
        smallMapView.addAnnotation(annotation)
    }


    @IBAction func btnFoundItClicked(_ sender: UIButton) {
        guard let treasure = treasure else { return }
        guard let inputCode = txtTreasureCode.text, !inputCode.isEmpty else {
            labelMessage.text = "Messages: Please enter the code!"
            labelMessage.textColor = .red
            return
        }
        

        if inputCode.trimmingCharacters(in: .whitespacesAndNewlines) == treasure.validationCode {
            labelMessage.text = "Messages: Success! You earned \(treasure.points) points! 🎉"
            labelMessage.textColor = .systemGreen
            

            let alert = UIAlertController(title: "Congratulations!", message: "You successfully claimed this treasure!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .default, handler: { _ in

                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
            
        } else {
            labelMessage.text = "Messages: Invalid Code. Try again!"
            labelMessage.textColor = .red
        }
    }
}
