//
//  TabBarController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 22.03.2023.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationItem.title = "Your Emission"
        if let navController = viewControllers?.first as? UINavigationController {
                // UINavigationController'ın rootViewController'ının gezinme çubuğuna başlık ekleyin
            navController.topViewController?.navigationItem.title = "Your Emission"
            }
        if let nav3Controller = viewControllers?.last as? UINavigationController {
            nav3Controller.topViewController?.navigationItem.title = "Past Emission"
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            print("log out")
            navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
}
