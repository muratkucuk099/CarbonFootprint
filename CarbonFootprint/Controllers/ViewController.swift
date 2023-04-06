//
//  ViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 1.03.2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore



class ViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signUpPress(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    print("Kullanıcı kaydı başarısız: \(error!.localizedDescription)")
                    return
                }
                
                let db = Firestore.firestore()
                let userCollection = db.collection("users").document(user.uid).collection(self.emailTextField.text!)
                    userCollection.document("userInfo").setData([
                    "email": self.emailTextField.text,
                ]) { err in
                    if let err = err {
                        print("Doküman oluşturulurken bir hata oluştu: \(err.localizedDescription)")
                    } else {
                        print("Doküman başarıyla oluşturuldu.")
                        self.performSegue(withIdentifier: K.welcomeToMainPage, sender: nil)
                    }
                }
            }
        }
    }
        @IBAction func signInPress(_ sender: UIButton) {
            if emailTextField.text != "" && passwordTextField.text != "" {
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authresult, error in
                    if error != nil {
                        self.errorFunction(title: "Error!", message: error?.localizedDescription ?? "Try Again")
                    } else {
                        print("Giriş yapıldı")
                        self.performSegue(withIdentifier: K.welcomeToMainPage, sender: nil)
                    }
                }
            } else {
                errorFunction(title: "Error!", message: "You can not enter null input")
            }
        }
        
        func errorFunction(title : String, message : String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            alert.addAction(okButton)
            self.present(alert, animated: true)
        }
    }

