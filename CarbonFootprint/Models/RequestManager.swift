//
//  RequestManager.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 26.03.2023.
//

import Foundation
import UIKit
import Firebase
import Charts
import FirebaseFirestore

struct RequestManager{
    let today = Date()
    let generalTypeDict : [String: Double] = ["Small Benzin Car": 0.1465, "Medium Benzin Car": 0.1847, "Large Benzin Car": 0.2764, "Small Diesel Car": 0.1399, "Medium Diesel Car": 0.1680, "Large Diesel Car": 0.2095, "Small Hybrid Car": 0.1033, "Medium Hybrid Car": 0.1099, "Large Hybrid Car": 0.1549, "Bus": 0.0965, "Coach": 0.0273, "Tram": 0.0286, "Tube": 0.0278, "National Rail": 0.0355, "International Rail": 0.0045, "Electric": 0.4195, "Natural Gas": 2.020, "Coal": 2.040, "LPG": 1.680, "Fuel Oil": 2.960, "Biogas": 0.0, "Plane": 0.0, "Small Bike": 0.0831, "Medium Bike": 0.1009, "Large Bike": 0.1325]
    
    let carArray = ["Small Benzin Car", "Medium Benzin Car", "Large Benzin Car", "Small Diesel Car", "Medium Diesel Car", "Large Diesel Car", "Small Hybrid Car", "Medium Hybrid Car", "Large Hybrid Car"]
    let busArray = ["Bus", "Tram", "Coach", "Tube", "National Rail", "International Rail"]
    let motorcycleArray = ["Small Bike", "Medium Bike", "Large Bike"]
    let warmArray = ["Natural Gas", "Coal", "LPG", "Fuel Oil", "Biogas"]
    let minutesArray = Array(stride(from: 0, through: 55, by: 5))
    let hoursArray = Array(0...10)
    let planeArray = ["Plane"]
    let electricArray = ["Electric"]
    let unitDict = ["Electric": "kwh", "Natural Gas": "m3", "Coal": "kg", "LPG": "lt", "Fuel Oil": "lt", "Biogas": "m3/tonne"]
    
    func getDate()-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: today)
        return dateString
    }
    func getUserCollection()-> CollectionReference{
        let documentId = UUID().uuidString
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        return userCollection
    }
    
    func request(userCollection: CollectionReference, energyType: String, completion: @escaping (Float) -> Void) {
       
            let query = userCollection.whereField("EnergyType",  isEqualTo: energyType)
        var totalAmount = 0.0
        
        DispatchQueue.global(qos: .background).async {
            query.getDocuments {  (querySnapshot, error) in
                if let error = error {
                    print("Hata oluştu: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let amount = data["CarbonEmission"] as? Double ?? 0
                        totalAmount += amount
                    }
                    DispatchQueue.main.async {
                        completion(Float(String(format: "%.2f", totalAmount))!)
                    }
                }
            }
        }
    }
    func requestChart(userCollection: CollectionReference, energyType: [String], completion: @escaping (Double) -> Void) {
          let query = userCollection.whereField("GeneralType",  in: energyType)
        var totalAmount = 0.0
        
        DispatchQueue.global(qos: .background).async {
            query.getDocuments {  (querySnapshot, error) in
                if let error = error {
                    print("Hata oluştu: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let amount = data["CarbonEmission"] as? Double ?? 0
                        totalAmount += amount
                    }
                    DispatchQueue.main.async {
                        completion(Double(String(format: "%.2f", totalAmount))!)
                    }
                }
            }
        }
    }
    
    func uploadData(type: String, navigationController: UINavigationController, energyType: String, emission: Double, viewController: UIViewController){
        let dateString = getDate()
        let documentId = UUID().uuidString
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        if emission != nil {
            userCollection.document(documentId).setData(["EnergyType": energyType, "Date": dateString, "date": FieldValue.serverTimestamp(), "GeneralType": type, "CarbonEmission": emission]) {err in if let err = err {
                print("Döküman eklenemedi \(err.localizedDescription)")
                alertDialog(navigationController: navigationController, viewController: viewController, title: "Error", message: "Your carbon emission could not be calculated!")
                
            } else {
                print("Döküman kaydı eklendi")
                let title = "\(emission) kg"
                let message = "You have released \(emission) kg of carbon emissions!"
                alertDialog(navigationController: navigationController, viewController: viewController, title: title, message: message)
            }
            }
        }
    }
    
    func uploadPlaneData(type: String, navigationController: UINavigationController, energyType: String, emission: Double, viewController: UIViewController){
        let dateString = getDate()
        let documentId = UUID().uuidString
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        userCollection.document(documentId).setData(["EnergyType": energyType, "Date": dateString, "date": FieldValue.serverTimestamp(), "GeneralType": type, "CarbonEmission": emission]) {err in if let err = err {
            print("Döküman eklenemedi \(err.localizedDescription)")
        } else {
            print("Döküman kaydı eklendi")
            
        }
        }
    }
    func alertDialog(navigationController: UINavigationController, viewController: UIViewController, title: String, message: String){
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            navigationController.popViewController(animated: true)
        }
        alertController.addAction(okButton)
        viewController.present(alertController, animated: true)
    }
}
//  "\(emission) kg", message: "You have released \(emission) kg of carbon footprint"
