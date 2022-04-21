//
//  ViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/03/2022.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
    
    private let segueToSigninFromRoot = "segueToLoginFromRoot"
    private var userEmail = ""
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
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
    
    func setUpElements() {
        Utilities.styleFilledButton(signupButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    
    func presentAlertLogin(userEmail: String) {
        
        let alert = UIAlertController(title: "Login", message: "Voulez vous continuer avec cet identifiant \(userEmail)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.deconnect()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.performSegue(withIdentifier: self.segueToSigninFromRoot, sender: self)
        })
        present(alert, animated: true, completion: nil)
    }
    
    func deconnect() {
        do {
            try Auth.auth().signOut()
        } catch {
            presentAlert(title: "Autorisation", message: "Erreur de déconnection")
        }
    }
}

