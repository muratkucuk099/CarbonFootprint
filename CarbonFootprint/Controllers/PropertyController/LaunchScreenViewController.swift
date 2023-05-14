//
//  LaunchScreenViewController.swift
//  CarbonFootprint
//
//  Created by Mac on 4.05.2023.
//

import UIKit
import Lottie
import FirebaseAuth

class LaunchScreenViewController: UIViewController {
    
    private var animationView: LottieAnimationView?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        animationView = .init(name: "plant")
        
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.animationSpeed = 1.6
        animationView!.loopMode = .loop
        view.addSubview(animationView!)
        animationView!.play()
        
        let currentUser = Auth.auth().currentUser
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentUser != nil {
                let board = UIStoryboard(name: "Main", bundle: nil)
                let tabBar = board.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
                tabBar.modalPresentationStyle = .fullScreen
                tabBar.modalTransitionStyle = .flipHorizontal
                self.present(tabBar, animated: true) {
                    UIView.animate(withDuration: 1.0, delay: 0.5, options: .autoreverse) {
                        self.view.alpha = 0
                    }
                }
            } else {
                let board = UIStoryboard(name: "Main", bundle: nil)
                let tabBar = board.instantiateViewController(withIdentifier: "login") as! UINavigationController
                tabBar.modalPresentationStyle = .fullScreen
                tabBar.modalTransitionStyle = .partialCurl
                self.present(tabBar, animated: true) {
                    UIView.animate(withDuration: 1.0, delay: 0.5, options: .autoreverse) {
                        self.view.alpha = 0
                    }
                    
                }
            }
            
        }
    }
}
