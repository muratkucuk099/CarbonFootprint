//
//  TreeRequest.swift
//  CarbonFootprint
//
//  Created by Mac on 11.04.2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

struct TreeRequest{
    
    var listener: ListenerRegistration?
    
    func animation(firstImage: String, secondImage: String, treeView: UIImageView, completion: @escaping (String) -> Void){
        let images = [UIImage(named: firstImage)!, UIImage(named: secondImage)!]
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.values = images.map { $0.cgImage as Any }
        animation.duration = 3.0
        animation.repeatCount = 1
        animation.fillMode = .forwards // son resim animasyon tamamlandıktan sonra ekranda kalacak
        animation.isRemovedOnCompletion = false // son resim animasyon tamamlandıktan sonra kaldırılmayacak
        treeView.layer.add(animation, forKey: "animateImage")
        let lastImage = secondImage
        DispatchQueue.main.async {
            completion(lastImage)
        }
    }
    func firebaseDayCalculation(userCollection: CollectionReference, completion: @escaping (Int) -> Void) {
        userCollection.order(by: "date", descending: false).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Hata: Belge bulunamadı.")
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM y"
            let firstDocument = documents.first
            if let firstDate = firstDocument!.data()["Date"] as? String {
                if let date = dateFormatter.date(from: firstDate) {
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let today = dateFormatter.string(from: Date())
                    let formattedDate = dateFormatter.string(from: date)
                    let startDate = dateFormatter.date(from: formattedDate)
                    let endDate = dateFormatter.date(from: today)
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day], from: startDate!, to: endDate!)
                    completion(components.day!)
                }
            }
        }
    }
    func removeListener(){
        listener?.remove()
    }
    mutating func requestTotal(userCollection: CollectionReference, completion: @escaping (Double) -> Void){
        listener = userCollection.addSnapshotListener { querySnapshot, error in
            
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                
                if (querySnapshot?.documents) != nil {
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
                            DispatchQueue.main.async {
                                completion(Double(String(format: "%.2f", totalAmount))!)
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
