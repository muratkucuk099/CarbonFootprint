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
        
        // 2. Start LottieAnimationView with animation name (without extension)
        
        animationView = .init(name: "plant")
        
        animationView!.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView!.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        animationView!.animationSpeed = 1.2
        animationView!.loopMode = .loop
        
        // 5. Adjust animation speed
        view.addSubview(animationView!)
        
        // 6. Play animation
        animationView!.play()
        var window: UIWindow?
        let currentUser = Auth.auth().currentUser
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
