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
    var treeRequest = TreeRequest()
    let requestManager = RequestManager()
    var lastImage = "yesil"
    var secondImage = "yesil"
    var total = 1.0
    var day = 1.0
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var firstStackView: UIStackView!
    @IBOutlet weak var treeView: UIImageView!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var thirdStackView: UIStackView!
    let message1 = "Bu birinci view'dan geliyor."
    let message2 = "Bu ikinci view'dan geliyor."
    let message3 = "Bu üçüncü view'dan geliyor."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        let views = [firstStackView, secondStackView, thirdStackView]
        firstStackView.tag = 1
        secondStackView.tag = 2
        thirdStackView.tag = 3
        for view in views {
            view?.layer.borderWidth = 2
            view?.layer.cornerRadius = 30
            view?.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            view?.addGestureRecognizer(tapGesture)
        }
        
    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        var message = ""
        switch sender.view?.tag {
        case 1:
            message = message1
        case 2:
            message = message2
        case 3:
            message = message3
        default:
            break
        }
        
        let alert = UIAlertController(title: "Tree Type", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        treeRequest.removeListener()
    }
    
    func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.treeRequest.animation(firstImage: self.lastImage, secondImage: self.secondImage, treeView: self.treeView) { lastImage in
                self.lastImage = lastImage
            }
        })
    }
    func manager() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        print(userCollection)
        self.averageLabel.text = "Daily Average Carbon Emission: 0.0 kg!"
        DispatchQueue.main.async {
            self.treeRequest.firebaseDayCalculation(userCollection: userCollection) { result in
                self.day = Double(result)
                
                self.treeRequest.requestTotal(userCollection: userCollection) { result in
                    
                    self.total = result
                    let average = self.total / self.day
                    self.averageLabel.text = "Daily Average Carbon Emission: \(String(format: "%.2f", average)) kg!"
                    if average < 15 {
                        self.secondImage = "yesil"
                    } else if  average < 25 {
                        self.secondImage = "kirmizi"
                    } else {
                        self.secondImage = "cut"
                    }
                    self.startAnimation()
                }
            }
        }
        self.indicatorView.stopAnimating()
        self.indicatorView.isHidden = true
    }
}
