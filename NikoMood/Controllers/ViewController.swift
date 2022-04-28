//
//  ViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/03/2022.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
  
    // MARK: - Properties
    
    private let authService: AuthService = AuthService()
    private let segueToSigninFromRoot = "segueToLoginFromRoot"
    private var userEmail = ""
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            guard let email = Auth.auth().currentUser!.email else { return  }
            presentAlertLogin(userEmail: email)
        }
    }
    
    // MARK: - Methods
    
    private func setUpElements() {
        Utilities.styleFilledButton(signupButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    
    private func presentAlertLogin(userEmail: String) {
        
        let alert = UIAlertController(title: "Login", message: "Voulez vous continuer avec cet identifiant \(userEmail)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.deconnect()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.performSegue(withIdentifier: self.segueToSigninFromRoot, sender: self)
        })
        present(alert, animated: true, completion: nil)
    }
    
    private func deconnect() {
        authService.signOut { result in
            if !result {
                self.presentFirebaseAlert(typeError: .errSignout, message: "Erreur Signout")
            }
        }
    }
}

