//
//  TreeViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 21.03.2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class TreeViewController: UIViewController {
    let treeRequest = TreeRequest()
    let requestManager = RequestManager()
    var lastImage = "yesil"
    var secondImage = "yesil"
    var total = 1.0
    var day = 1.0
    @IBOutlet weak var treeView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        manager()
    }
    
    func manager(){
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        requestManager.firebaseDayCalculation(userCollection: userCollection) { result in
            self.day = Double(result + 1)
        }
        requestManager.requestTotal(userCollection: userCollection) { result in
            print(self.total, self.day)
            if result != 0 {
                
                self.total = result + 1
                
                let average = self.total / self.day
                print(average)
                if 50 > average {
                    self.secondImage = "yesil"
                } else if 50 < average {
                    self.secondImage = "kirmizi"
                }
            }
           
            self.treeRequest.animation(firstImage: self.lastImage, secondImage: self.secondImage, treeView: self.treeView) { lastImage in
                self.lastImage = lastImage
                print(self.secondImage, lastImage)
                
            }
        }
        
        
    }
}
