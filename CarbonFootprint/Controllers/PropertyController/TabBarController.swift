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
        if let navThirdController = viewControllers?.last as? UINavigationController {
            navThirdController.topViewController?.navigationItem.title = "Past Emission"
        }
        if let navSecondController = viewControllers?[1] as? UINavigationController {
            navSecondController.topViewController?.navigationItem.title = "Average Emission Tree"
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
