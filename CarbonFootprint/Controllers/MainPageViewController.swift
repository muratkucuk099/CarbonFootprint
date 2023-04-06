//
//  MainPageViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 21.03.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class MainPageViewController: UIViewController {
    
    @IBOutlet weak var totalCalculationLabel: UILabel!
    @IBOutlet weak var houseHoldCalculationLabel: UILabel!
    @IBOutlet weak var transportationCalculationLabel: UILabel!
    @IBOutlet weak var houseHoldProgress: UIProgressView!
    @IBOutlet weak var transportationProgress: UIProgressView!
    var total: Float = 0.0
    var tranportation: Float = 0.0
    var household: Float = 0.0
    
    var requestManager = RequestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseGetData()
    }
    
    func firebaseGetData() {
        
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        userCollection.addSnapshotListener { querySnapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                if let queryDocument = querySnapshot?.documents {
                    let query = userCollection.whereField("CarbonEmission",  isGreaterThan: 0)
                    var totalAmount = 0.0
                    query.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Hata oluştu: \(error.localizedDescription)")
                        } else {
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                let amount = data["CarbonEmission"] as? Double ?? 0
                                totalAmount += amount
                            }
                            self.totalCalculationLabel.text = "\(String(format: "%.2f", totalAmount))"
                            
                        }
                    }
                    
                    self.requestManager.request(userCollection: userCollection, energyType: "Household", labelType: self.houseHoldCalculationLabel) {
                        result in
                        self.houseHoldProgress.progress = Float(result) / Float(totalAmount)
                        
                    }
                    self.requestManager.request(userCollection: userCollection, energyType: "Transportation", labelType: self.transportationCalculationLabel) {
                        result in
                        self.transportationProgress.progress = Float(result) / Float(totalAmount)
                    }
                }
            }
        }
    }
}
