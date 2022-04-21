//
//  NikorecordViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 24/03/2022.
//

import UIKit
import FirebaseAuth
import Firebase

class NikoRecordViewController: UIViewController {

    // MARK: - Properties
    
    let nikoFirestoreManager =  NikoFirestoreManager.shared

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let useremail = Auth.auth().currentUser?.email
        yourEmail.text = useremail
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        causeTextField.text = nikoFirestoreManager.currentNiko.nikoCause
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(validerUIButton)
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        deconnect()
    }
    
    @IBAction func superUIButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            razNikoButton()
            hideIshikawa()
            sender.isSelected = true
            nikoFirestoreManager.currentNiko.nikoStatus = "Super"
            nikoFirestoreManager.currentNiko.nikoRank = 10
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
            nikoFirestoreManager.currentNiko.nikoStatus = "NTR"
            nikoFirestoreManager.currentNiko.nikoRank = 5
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
            nikoFirestoreManager.currentNiko.nikoStatus = "Tought"
            nikoFirestoreManager.currentNiko.nikoRank = 0
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
            nikoFirestoreManager.currentNiko.niko5M = "methode"
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
            nikoFirestoreManager.currentNiko.niko5M = "matiere"
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
            nikoFirestoreManager.currentNiko.niko5M = "machine"
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
            nikoFirestoreManager.currentNiko.niko5M = "maindoeuvre"
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
            nikoFirestoreManager.currentNiko.niko5M = "milieu"
            milieuUIButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            milieuUIButton.setImage(UIImage(systemName: "poweroff"), for: .normal)
        }
    }
    
    
    @IBAction func displayCause(_ sender: UIButton) {
        let vc = LibraryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func validerNikoRecordButtonTapped(_ sender: UIButton) {
        // validate Data
        nikoFirestoreManager.currentNiko.nikoComment = commentUITextField.text ?? ""
//******************************* validation saisie à faire
        
        // Store the record in Firestore
        nikoFirestoreManager.storeNikoRecord(record: nikoFirestoreManager.currentNiko)
    }
    
    @IBAction func actionDatePicker(_ sender: UIDatePicker) {
        nikoFirestoreManager.currentNiko.date = sender.date
    }
    
    
    
    
    private func deconnect() {
        do {
            try Auth.auth().signOut()
            transitionToStart()
        } catch {
            print("Error signing out ")
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
    }

}


