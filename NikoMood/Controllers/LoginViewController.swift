//
//  LoginViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/03/2022.
//

import UIKit

class LoginViewController: UIViewController {
 
    // MARK: - Properties
    //let nikoFirestoreManager =  NikoFirestoreManager.shared
    private let authService: AuthService = AuthService()
    private let databaseManager: DatabaseManager = DatabaseManager()
    private let segueToTabbarFromLogin = "segueToTabbarFromLogin"
    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
 
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
 
        
        authService.isUserConnected { isConnected in
            switch isConnected {
            case true:
                self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
//                self.databaseManager.getUserData(with: self.authService.currentUID!) { (result) in
//                    DispatchQueue.main.async {
//                        print("dans dispatch get user data de signin view")
//                        switch result {
//                        case .success(let data):
//                            self.currentNiko = data
//                            print("currentNiko userID: \(self.currentNiko.userID)")
//                            self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
//
//                        case .failure(let error):
//                            self.presentFirebaseAlert(typeError: error, message: "")
//                        }
//                    }
//                }
            case false:
                print("No user selected in Login view")
            }
        }
    
        
    }
    
    
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        authService.signIn(email: email, password: password) { isSuccess in
            DispatchQueue.main.async {
                switch isSuccess {
                case true:
                    self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
//            case .success(let authResult):
//                let userID = authResult.user.uid
//                self.databaseManager.getUserData(with: userID) { (result) in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let data):
//                            self.currentNiko = data
//                            self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
//                        case .failure(let error):
//                            self.presentFirebaseAlert(typeError: error, message: "")
//                        }
//                    }
//                }

                case false:
                    self.presentFirebaseAlert(typeError: .errSignin, message: self.currentNiko.error!)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
}



