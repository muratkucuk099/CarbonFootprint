//
//  MapViewController.swift
//  CarbonFootprint
//
//  Created by Mac on 7.04.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let calculationManager = CalculationManager()
    let requestManager = RequestManager()
    var type = ""
    var lastLocation: CLLocation?
    var totalDistance: CLLocationDistance = 0.0
    var totalKm = ""
    var isRecord = false
    var carbonValue = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        // konum verilerini alma
        
        
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        isRecord = true
        print("startttt")
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        isRecord = false
        print("stopp")
    }
    
    @IBAction func calculateButton(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        
        if let carbonValue = requestManager.generalTypeDict[type]{
            let carbonEmission = calculationManager.calculateWithKM(carbonValue: carbonValue, amount: Double(totalKm)!)
            if carbonEmission != 0 {
                requestManager.uploadData(type: type, navigationController: self.navigationController!, energyType: "Transportation", emission: carbonEmission, viewController: self)
            } else {
                alertDialog(viewController: self, title: "Zero Emission!", message: "You need to release carbon emission for calculation. Press play button!")
            
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updateeeeee")
        guard let newLocation = locations.last else { return }
               
               if let lastLocation = self.lastLocation {
                   let distance = lastLocation.distance(from: newLocation) / 1000
                   if isRecord{
                       if distance > 0.0001{
                           totalDistance += distance
                       }
                   }
                   var locationCoordinate = locations[locations.count - 1].coordinate
                   let location = CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                   let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                   let region = MKCoordinateRegion(center: location, span: span)
                   mapView.setRegion(region, animated: true)
                       mapView.showsUserLocation = true
                   
               }
        totalKm = String(format: "%.2f", totalDistance)
        distanceLabel.text = totalKm
               self.lastLocation = newLocation
               print("Total distance: \(totalDistance) meters")
       
    }
    func alertDialog(viewController: UIViewController, title: String, message: String){
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
        }
        alertController.addAction(okButton)
        viewController.present(alertController, animated: true)
    }
    
}
