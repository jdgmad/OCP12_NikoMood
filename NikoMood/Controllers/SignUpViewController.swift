//
//  SignUpViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/03/2022.
//

import UIKit
//import FirebaseAuth
//import Firebase
//import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    
    //let nikoFirestoreManager = NikoFirestoreManager.shared
    private let authService: AuthService = AuthService()
    private let databaseManager: DatabaseManager = DatabaseManager()
    private let segueToTabbarFromSignup = "segueToTabbarFromSignup"
    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")

    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showError("")
    }
    
    // MARK: - Actions
    
    @IBAction func signupTapped(_ sender: UIButton) {
        // Validate the fields
        let error = validateFields()
        if error != nil {
            // There's something wrong wirh the fields, show error message
            showError(error!)
        }
        else {
            createUser()
        }
    }
    
    // MARK: - Methods
    
    private func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(password2TextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signupButton)
    }
    
    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    private func validateFields() -> String? {
        // Check that all fields are filled in
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return "Error in email text"}
        guard let cleanedPassword2 = password2TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return "Error in first password text"}
        guard let cleanedPassword = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return "Error in second password text"}
        if email == "" || cleanedPassword == "" {
            return "Please fill in all the fields"
        }
        // Check if the password is secure

        if Utilities.isPasswordValid(cleanedPassword2) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number"
        }
        if cleanedPassword != cleanedPassword2 { return "Passwords are not identical"}
        if Utilities.isValidEmail(email: email) == false {
            return "Your email do not respect the email format"
        }
        return nil
    }
    
    private func createUser() {
        //var userDocumentID = String()
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        // Check if the email is in the company list
        
        

        // Create the user
        authService.signUp(email: email, password: password) { isSuccess in
            self.databaseManager.getUserData(with: self.authService.currentUID!) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.currentNiko = data
                        self.performSegue(withIdentifier: self.segueToTabbarFromSignup, sender: self)
                    case .failure(let error):
                        self.presentFirebaseAlert(typeError: error, message: "")
                    }
                }
            }
        }
    }
    
    private func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    

}


