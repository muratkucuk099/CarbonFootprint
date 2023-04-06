//
//  InformationViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 19.03.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var informationArray = [String]()
    
    
    
    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
                
        
      
       firebaseGetData()
        
    }
    func firebaseGetData() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!).order(by: "date", descending: true)
            userCollection.addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    
                    if let queryDocument = querySnapshot?.documents {
                        self.informationArray.removeAll()
                       
                        for document in queryDocument{
                            
                            if let type = document.get("GeneralType") as? String{
                                if let energy = document.get("EnergyType") as? String{
                                    if let amount = document.get("CarbonEmission") as? Double{
                                        if let date = document.get("Date") as? String{
                                            let information = "On \(date) you released \(amount) kg \(energy)  \(type) "
                                            self.informationArray.append(information)
                                        }
                                    }
                                   
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                    
                }
            }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! FeedTableViewCell
        cell.label.text = informationArray[indexPath.row]
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informationArray.count
    }
    
    

    
}
