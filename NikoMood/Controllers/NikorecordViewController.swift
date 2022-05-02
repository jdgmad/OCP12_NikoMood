//
//  NikorecordViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 24/03/2022.
//

import UIKit
//import FirebaseAuth
//import Firebase

class NikoRecordViewController: UIViewController {

    // MARK: - Properties
    private let authService: AuthService = AuthService()
    private let databaseManager: DatabaseManager = DatabaseManager()
    //let nikoFirestoreManager =  NikoFirestoreManager.shared
    var currentNiko = NikoRecord(userID: "user", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
    //var userUID = String()


    // MARK: - Outlets
    
    @IBOutlet weak var superUIButton: UIButton!
    @IBOutlet weak var ntrUIButton: UIButton!
    @IBOutlet weak var toughtUIButton: UIButton!
    
    @IBOutlet weak var methodeUIButton: UIButton!
    @IBOutlet weak var matiereUIButton: UIButton!
    @IBOutlet weak var machineUIButton: UIButton!
    @IBOutlet weak var maindoeuvreUIButton: UIButton!
    @IBOutlet weak var milieuUIButton: UIButton!
    
    @IBOutlet weak var stackView2M: UIStackView!
    @IBOutlet weak var stackView3M: UIStackView!
    @IBOutlet weak var ishikawaUIImage: UIImageView!
    @IBOutlet weak var causeLabel: UILabel!
    @IBOutlet weak var causeTextField: UITextField!
    @IBOutlet weak var nextUIImage: UIImageView!
    @IBOutlet weak var commentUITextField: UITextField!
    @IBOutlet weak var yourEmail: UITextField!
    @IBOutlet weak var validerUIButton: UIButton!
    @IBOutlet weak var causeUIButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let  useremail = authService.currentEmail
        yourEmail.text = useremail
        getUserData()
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        causeTextField.text = currentNiko.nikoCause
    }
    
    
    // MARK: - IBActions
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        deconnect()
    }
    
    @IBAction func superUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            razNikoButton()
            hideIshikawa()
            sender.isSelected = true
            currentNiko.nikoStatus = "Super"
            currentNiko.nikoRank = 10
            superUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            superUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func ntrUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            razNikoButton()
            hideIshikawa()
            sender.isSelected = true
            currentNiko.nikoStatus = "NTR"
            currentNiko.nikoRank = 5
            ntrUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            ntrUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func toughtUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            razNikoButton()
            displayIshikawa()
            sender.isSelected = true
            currentNiko.nikoStatus = "Tought"
            currentNiko.nikoRank = 0
            toughtUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            toughtUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func methodeUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            raz5MButton()
            sender.isSelected = true
            currentNiko.niko5M = "methode"
            methodeUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            methodeUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func matiereUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            raz5MButton()
            sender.isSelected = true
            currentNiko.niko5M = "matiere"
            matiereUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            matiereUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func machineUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            raz5MButton()
            sender.isSelected = true
            currentNiko.niko5M = "machine"
            machineUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            machineUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func maindoeuvreUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            raz5MButton()
            sender.isSelected = true
            currentNiko.niko5M = "maindoeuvre"
            maindoeuvreUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            maindoeuvreUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func milieuUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            raz5MButton()
            sender.isSelected = true
            currentNiko.niko5M = "milieu"
            milieuUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            milieuUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    @IBAction func displayCauseButton(_ sender: UIButton) {
        let vc = LibraryViewController()
        vc.completion = {[weak self] currentNiko in
            self?.currentNiko = currentNiko
        }
        vc.currentNiko = currentNiko
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func validerNikoRecordButtonTapped(_ sender: UIButton) {
        // validate Data
        currentNiko.nikoComment = commentUITextField.text ?? ""
        // Ckeck if a record already exist at the same date
        databaseManager.checkIfRecordExist(uid: currentNiko.userID, dateSelected: currentNiko.date) { (result) in
            DispatchQueue.main.async {
                switch result {
                case true:
                    self.presentFirebaseAlert(typeError: .errWritingData, message: "Cette date contient déjà un enregistrement")
                case false:
                    // Store the record in Firestore
                    self.databaseManager.storeNikoRecord(record: self.currentNiko) { (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case true:
                                print("Niko record has been stored")
                            case false:
                                    self.presentFirebaseAlert(typeError: .errWritingData, message: "Erreur enregistrement de données")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func actionDatePicker(_ sender: UIDatePicker) {
        currentNiko.date = sender.date
    }
    
    // MARK: - Methods
    
    private func getUserData() {
        guard let uid = authService.currentUID else { return}
        //userUID = uid
        databaseManager.getUserData(with: uid) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.currentNiko = data
                case .failure(let error):
                    self.presentFirebaseAlert(typeError: error, message: "Erreur récupération user Data")
                }
            }
        }
    }
    
    private func setUpElements() {
        Utilities.styleFilledButton(validerUIButton)
        causeUIButton.titleLabel!.text = ""
        causeTextField.rightView = causeUIButton
        causeTextField.rightViewMode = .always
        transitionToStart()
    }
    
    private func deconnect() {
        authService.signOut { result in
            if result {
                self.transitionToStart()
            }
            else {
                self.presentFirebaseAlert(typeError: .errSignout, message: "Erreur Signout")
            }
        }
    }
    
    private func hideIshikawa () {
        stackView2M.isHidden = true
        stackView3M.isHidden = true
        ishikawaUIImage.isHidden = true
        causeLabel.isHidden = true
        causeTextField.isHidden = true
        causeUIButton.isHidden = true
    }
    
    private func displayIshikawa () {
        stackView2M.isHidden = false
        stackView3M.isHidden = false
        ishikawaUIImage.isHidden = false
        causeLabel.isHidden = false
        causeTextField.isHidden = false
        causeUIButton.isHidden = false
    }
    
    private func transitionToStart() {
        let startViewController  = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.startViewController)
        view.window?.rootViewController = startViewController
        view.window?.makeKeyAndVisible()
    }
    
    private func razNikoButton () {
        ntrUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        ntrUIButton.isSelected = false
        superUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        superUIButton.isSelected = false
        toughtUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        toughtUIButton.isSelected = false
        causeTextField.text = ""
        commentUITextField.text = ""
    }
    
    private func raz5MButton () {
        methodeUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        methodeUIButton.isSelected = false
        matiereUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        matiereUIButton.isSelected = false
        machineUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        machineUIButton.isSelected = false
        maindoeuvreUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        maindoeuvreUIButton.isSelected = false
        milieuUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        milieuUIButton.isSelected = false
        causeTextField.text = ""
        commentUITextField.text = ""
    }

}


