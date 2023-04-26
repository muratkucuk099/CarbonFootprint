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
    
    
    @IBOutlet weak var tableView: UITableView!
    var informationArray = [Information]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        firebaseGetData()
        let exitButton = UIBarButtonItem(title: "Çıkış", style: .plain, target: self, action: #selector(exitTapped))
        exitButton.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        navigationItem.rightBarButtonItem = exitButton
    }
    
    @objc func exitTapped() {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "login") as! UINavigationController
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        } catch {
            print("Çıkış yaparken hata oluştu")
        }
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
                                        if let documentId = document.documentID as? String{
                                            let informationString = "On \(date) you released \(amount) kg \(energy)  \(type)"
                                            let information = Information(documentId: documentId, informationString: informationString)
                                            self.informationArray.append(information)
                                        }
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
        cell.label.text = informationArray[indexPath.row].informationString
        return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informationArray.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentID = informationArray[indexPath.row].documentId
            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            let userCollection = db.collection("users").document(user!.uid).collection(user!.email!).document(documentID)
                userCollection.delete() { error in
                if let error = error {
                       print("Hata oluştu: \(error.localizedDescription)")
                   } else {
                       print("Belge silindi.")
                   }
            }
            informationArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    
}
