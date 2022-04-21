//
//  SignUpViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/03/2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    
    let nikoFirestoreManager = NikoFirestoreManager.shared
    private let segueToTabbarFromSignup = "segueToTabbarFromSignup"


    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showError("")
    }
    
    
    func setUpElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(pseudoTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signupButton)
    }
    
    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        // Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all the fields"
        }
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number"
        }
        return nil
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
    
    func createUser() {
        var userDocumentID = String()
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // Check if the email is in the company list

        // Create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            // Check for errors
            if err != nil {
                // There was an error creating the user
                self.showError("Error creating user")
            }
            else {
                // User was created successfully, now store the Auth user ID in the collection users
                guard let authUserID = result?.user.uid else { return }
                // Check if the email is in the company list
                let db = Firestore.firestore()
                let usersRef = db.collection("users")
                usersRef.whereField("email", isEqualTo: email)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            if querySnapshot?.documents.count == 1 {    // means that the email is in the company list
                                for document in querySnapshot!.documents {
                                    userDocumentID = document.documentID
                                    //print("\(document.documentID) => \(document.data())")
                                    let userDoc = db.collection("users").document(userDocumentID)
                                    userDoc.updateData(["userID": authUserID]) { err in
                                        if let err = err {
                                            self.showError("Error updating document: \(err)")
                                        } else {
                                            print("Document successfully updated")
                                            // Transition to the home screen
                                            
                                            self.nikoFirestoreManager.retrieveUserData(uid: authUserID) { (result) in
                                                switch result {
                                                case .success(_):
                                                    //self.performSegue(withIdentifier: self.segueToTabbarFromLogin, sender: self)
                                                    self.performSegue(withIdentifier: self.segueToTabbarFromSignup, sender: self)
                                                case .failure(let error):
                                                    self.presentFirebaseAlert(typeError: error, message: "")
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                self.showError("Vous n'êtes pas identifié dans la liste des salariés")
                            }
                        }
                    }
            }
        }
    }
    
                
                
//    func createUser() {
//        var userDocumentID = String()
//        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        // Check if the email is in the company list
//        let db = Firestore.firestore()
//        let usersRef = db.collection("users")
//        usersRef.whereField("email", isEqualTo: email)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    if querySnapshot?.documents.count == 1 {    // means that the email is in the company list
//                        for document in querySnapshot!.documents {
//                            userDocumentID = document.documentID
//                            //print("\(document.documentID) => \(document.data())")
//                        }
//                        // Create the user
//                        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
//                            // Check for errors
//                            if err != nil {
//                                // There was an error creating the user
//                                self.showError("Error creating user")
//                            }
//                            else {
//                                // User was created successfully, now store the Auth user ID in the collection users
//                                guard let authUserID = result?.user.uid else { return }
//                                let db = Firestore.firestore()
//                                let userDoc = db.collection("users").document(userDocumentID)
//
//                                userDoc.updateData(["userID": authUserID]) { err in
//                                    if let err = err {
//                                        self.showError("Error updating document: \(err)")
//                                    } else {
//                                        print("Document successfully updated")
//                                    }
//                                }
//                                // Transition to the home screen
//                                self.performSegue(withIdentifier: self.segueToTabbarFromSignup, sender: self)
//                            }
//                        }
//                    }else {
//                        self.showError("Vous n'êtes pas identifié dans la liste des salariés")
//                    }
//                }
//            }
//    }
    
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}


