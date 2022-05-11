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
            case false:
                print("No user selected in Login view")
            }
        }
    
        
    }
    
    
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        // Validate the fields
        let error = validateFields()
        if error != nil {
            // There's something wrong wirh the fields, show error message
            showError(error!)
        }
        else {
            // Signing in the user
            authService.signIn(email: email, password: password) { isSuccess in
                DispatchQueue.main.async {
                    switch isSuccess {
                    case true:
                        self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
                    case false:
                        self.presentFirebaseAlert(typeError: .errSignin, message: self.currentNiko.error!)
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    private func validateFields() -> String? {

        // Check that all fields are filled in
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return "Error in email text".localized()}
        guard let cleanedPassword = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return "Error in second password text".localized()}
        if email == "" || cleanedPassword == "" {
            return "Please fill in all the fields".localized()
        }
        // Check if the password is secure
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number".localized()
        }
        if Utilities.isValidEmail(email: email) == false {
            return "Your email do not respect the email format".localized()
        }
        return nil
    }
    
    private func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    private func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}



