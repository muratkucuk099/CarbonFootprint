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
    let requestManager = RequestManager()
    
    func animation(firstImage: String, secondImage: String, treeView: UIImageView, completion: @escaping (String) -> Void){
        let images = [UIImage(named: firstImage)!, UIImage(named: secondImage)!]
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.values = images.map { $0.cgImage as Any }
        animation.duration = 1.0
        animation.repeatCount = 1
        animation.fillMode = .forwards // son resim animasyon tamamlandıktan sonra ekranda kalacak
        animation.isRemovedOnCompletion = false // son resim animasyon tamamlandıktan sonra kaldırılmayacak
        treeView.layer.add(animation, forKey: "animateImage")
        let lastImage = secondImage
        DispatchQueue.main.async {
            completion(lastImage)
        }
    }
    func calculateDailyEmission(total: Double, day: Double, completion: @escaping (Double) -> Void) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
       
        DispatchQueue.main.async {
            completion(Double(String(format: "%.2f", day/total))!)
        }
    }
}
