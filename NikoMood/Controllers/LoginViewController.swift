//
//  LoginViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/03/2022.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
 
    // MARK: - Properties
    let nikoFirestoreManager =  NikoFirestoreManager.shared
    private let segueToTabbarFromLogin = "segueToTabbarFromLogin"
 
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
        
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser?.uid
            print(" Login viewer")
            nikoFirestoreManager.retrieveUserData(uid: uid!) { (result) in
                switch result {
                case .success(_):
                    self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
                    
                case .failure(let error):
                    self.presentFirebaseAlert(typeError: error, message: "")
                }
            }
        }
    }
    
    func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }

    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        nikoFirestoreManager.loginUser(email: email, password: password) { (result) in
            
            switch result {
                
            case .success(_):
                self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
                
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: self.nikoFirestoreManager.currentNiko.error!)
            }
            
            self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
        
        }
    }
}

