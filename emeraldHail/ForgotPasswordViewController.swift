//
//  ForgotPasswordViewController.swift
//  emeraldHail
//
//  Created by Enrique Torrendell on 12/12/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var forgotView: UIView!
    
    let store = DataStore.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editingFamilyName(_ sender: UITextField) {
        if emailTextField.text?.isEmpty == true {
            sendButton.isEnabled = false
            sendButton.backgroundColor = Constants.Colors.submarine
        } else {
            sendButton.isEnabled = true
            sendButton.backgroundColor = Constants.Colors.scooter
        }
    }
    
    // MARK: - Methods
    func setupViews() {
        view.backgroundColor = Constants.Colors.transBlack
        forgotView.docItStyleView()
        cancelButton.docItStyle()
        emailTextField.docItStyle()
        sendButton.docItStyle()
        sendButton.isEnabled = false
        sendButton.backgroundColor = Constants.Colors.submarine
        emailTextField.becomeFirstResponder()
    }
    
    func sendEmail() {
        sendButton.isEnabled = false
        guard let userInput = emailTextField.text else { return }
        FIRAuth.auth()?.sendPasswordReset(withEmail: userInput, completion: { (error) in
            if let error = error {
                // TODO: Handle errors
                print(error.localizedDescription)
                self.sendButton.isEnabled = true
            }
        })
        dismiss(animated: true, completion: nil)
    }
}
