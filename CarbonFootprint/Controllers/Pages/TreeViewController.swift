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
    var tag = 1
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
    let message1 = "Congratulations! The leaves of our digital tree are lush. You're doing an excellent job controlling your carbon emissions. Your contributions are important in preserving our natural resources and fighting climate change worldwide. By continuing on this path, you'll play a vital role in taking steps toward a sustainable future."
    let message2 = "The leaves of our digital tree are at a falling level. This is a good start, but you can reduce your carbon emissions for a more sustainable lifestyle. For example, you can take many simple steps such as energy conservation, switching to renewable energy sources, recycling, and choosing sustainable food options. Let's work together to reduce your carbon footprint!"
    let message3 = "Unfortunately, our digital tree has completely withered. Your carbon footprint is at a high level. This situation can cause serious harm to our environment and planet. Therefore, we recommend that you be more careful in your daily life. For example, you can reduce your energy consumption at home by using energy-saving bulbs. You can reduce the carbon footprint of the agriculture sector by buying organic products from local markets. You can avoid using cars and choose public transportation or at least carpool. Even small changes can make a big difference."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        let views = [firstStackView, secondStackView, thirdStackView]
        for view in views {
            view?.layer.borderWidth = 2
            view?.layer.cornerRadius = 30
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        treeRequest.removeListener()
    }
    
    @IBAction func infoPressed(_ sender: UIButton) {
        var message = ""
        switch tag{
        case 1:
            message = message1
        case 2:
            message = message2
        case 3:
            message = message3
        default:
            break
        }
        
        let alert = UIAlertController(title: "Digital Tree", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "Marker Felt Wide", size: 30), NSAttributedString.Key.foregroundColor: UIColor(red: 9/255, green: 118/255, blue: 15/255, alpha: 1)]
        let titleAttrString = NSMutableAttributedString(string: "Digital Tree", attributes: titleFont as [NSAttributedString.Key : Any])
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "Marker Felt Thin", size: 18),
                           NSAttributedString.Key.foregroundColor: UIColor(red: 50/255, green: 28/255, blue: 13/255, alpha: 1)]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont as [NSAttributedString.Key : Any])
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        present(alert, animated: true, completion: nil)
        
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
                        self.tag = 1
                    } else if  average < 25 {
                        self.secondImage = "kirmizi"
                        self.tag = 2
                    } else {
                        self.secondImage = "cut"
                        self.tag = 3
                    }
                    self.startAnimation()
                    self.indicatorView.stopAnimating()
                    self.indicatorView.isHidden = true
                }
            }
        }
    }
}
