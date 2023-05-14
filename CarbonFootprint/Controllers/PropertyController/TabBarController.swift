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
            navController.topViewController?.navigationItem.title = "Your Emission"
            
        }
        if let navThirdController = viewControllers?.last as? UINavigationController {
            navThirdController.topViewController?.navigationItem.title = "Past Emission"
        }
        if let navSecondController = viewControllers?[1] as? UINavigationController {
            navSecondController.topViewController?.navigationItem.title = "Daily Average Emission"
        }
        tabBar.unselectedItemTintColor = UIColor(red: 50/255, green: 28/255, blue: 13/255, alpha: 1)
        let font = UIFont(name: "Marker Felt Thin", size: 13)!
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(textAttributes, for: .normal)
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
