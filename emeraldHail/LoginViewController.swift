//
//  LoginViewController.swift
//  emeraldHail
//
//  Created by Enrique Torrendell on 11/18/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // actions
    
    @IBAction func signIn(_ sender: UIButton) {
    login()
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        performSegue(withIdentifier: "segueRegister", sender: self)
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        performSegue(withIdentifier: "segueForgot", sender: self)

    }
    
    
    
   
    // functions
    func login() {
        
        guard let email = textEmail.text else { return }
        guard let password = textPassword.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                
            } else if (FIRAuth.auth()?.currentUser) != nil {
                
                self.performSegue(withIdentifier: "segueFamily", sender: nil)
                
            }
        }
    }
}

class ForgotViewController: UIViewController {
    
    @IBOutlet weak var textEmail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func sendPassword(_ sender: UIButton) {
        print("send email")
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
