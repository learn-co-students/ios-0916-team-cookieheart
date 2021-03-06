//
//  WelcomeViewController.swift
//  emeraldHail
//
//  Created by Henry Ly on 11/24/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import LocalAuthentication
import GoogleSignIn
import Firebase
import FirebaseDatabase

class WelcomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var touchID: UIButton!
    
    // MARK: - Properties
    var store = DataStore.sharedInstance
    var context = LAContext()
    let hasLoginKey = UserDefaults.standard.bool(forKey: "hasFamilyKey")
    let MyKeychainWrapper = KeychainWrapper()
    
    // MARK: - Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFamilyId()
        setupViews()
        checkTouchID()
        store.fillWeightDataInLbs()
        store.fillHeightDataInCm()
        store.fillWeightDataInKg()
        store.fillWeightDataInG()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // MARK: - Actions
    @IBAction func createAccountPressed(_ sender: Any) {
        createAccount.isEnabled = false
        NotificationCenter.default.post(name: Notification.Name.openRegisterVC, object: nil)
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        signIn.isEnabled = false
        NotificationCenter.default.post(name: Notification.Name.openLoginVC, object: nil)
    }
    
    @IBAction func touchId(_ sender: UIButton) {
        googleOrNot()
    }
    
    // MARK: - Methods
    func updateFamilyId() {
        let familyID = UserDefaults.standard.value(forKey: "family") as? String
        if familyID != nil {
            Store.user.familyId = familyID!
        }
    }
    
    func setupViews() {
        view.backgroundColor = Constants.Colors.desertStorm
        createAccount.docItStyle()
        signIn.docItStyle()
        signIn.layer.borderWidth = 1
        signIn.layer.borderColor = Constants.Colors.submarine.cgColor
    }
    
    func checkTouchID() {
        touchID.isHidden = true
        let touchIDValue = UserDefaults.standard.value(forKey:"touchID") as? String
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) && touchIDValue == "true" {
            googleOrNot()
            touchID.isHidden = false
        }
    }
    
    func googleOrNot() {
        let accessKey = UserDefaults.standard.value(forKey:"auth") as? String
        accessKey == "google" ? authenticateUserGoogle() : authenticateUser()
    }
    
    // MARK: Methods Touch ID
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                if success {
                    self.navigateToAuthenticatedVC()
                } else {
                    if let error = error as NSError? {
                        let message = self.errorMessageAuthentication(errorCode: error.code)
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
                    }
                }
            })
        } else {
            showAlertViewforNoBiometrics()
            return
        }
    }
    
    func authenticateUserGoogle() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Touch the Home button to log on."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                    if let error = error as NSError? {
                        let message = self.errorMessageAuthentication(errorCode: error.code)
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
                    } else {
                        DispatchQueue.main.async {
                            GIDSignIn.sharedInstance().signIn()
                        }
                    }
            })
        } else {
            showAlertViewforNoBiometrics()
            return
        }
    }
    
    func navigateToAuthenticatedVC() {
        let email = UserDefaults.standard.value(forKey:"email") as? String
        let userID = UserDefaults.standard.value(forKey: "user") as? String
        let password = MyKeychainWrapper.myObject(forKey: "v_Data") as? String
        Store.user.email = email!
        Store.user.id = userID!
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            if error != nil {
                // TODO: Handle error
                return
            }
            Database.user.child((user?.uid)!).observe(.value, with: { snapshot in
                DispatchQueue.main.async {
                    var data = snapshot.value as? [String:Any]
                    guard let familyID = data?["familyID"] as? String else { return }
                    Store.user.id = (user?.uid)!
                    Store.user.familyId = familyID
                    Store.family.id = familyID
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        NotificationCenter.default.post(name: .openfamilyVC, object: nil)
                    })
                }
            })
        }
    }
    
    func showAlertViewforNoBiometrics() {
        showAlertViewWithTitle(title: "Error", message: "This device does not have a Touch ID sensor.")
    }
    
    func showAlertViewWithTitle(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        ac.addAction(ok)
        present(ac, animated: true, completion: nil)
    }
    
    func showAlertViewAfterEvaluatingPolicyWithMessage(message: String) {
        showAlertViewWithTitle(title: "Error", message: message)
    }
}

extension WelcomeViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let idToken = user.authentication.idToken,
            let accessToken = user.authentication.accessToken else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { loggedInUser, error in
            guard let userID = loggedInUser?.uid, let email = loggedInUser?.email else { return }
            Store.user.email = email
            Store.user.id = userID
            Database.user.child(userID).observe(.value, with: { snapshot in
                if let data = snapshot.value as? [String:Any] {
                    guard let familyID = data["familyID"] as? String else { return }
                    Store.user.familyId = familyID
                    Store.family.id = familyID
                    self.addDataToKeychain(
                        userID: Store.user.id,
                        familyID: Store.user.familyId,
                        email: Store.user.email,
                        auth: "google")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        NotificationCenter.default.post(name: Notification.Name.openfamilyVC, object: nil)
                    })
                }
            })
        })
    }
    
    func addDataToKeychain(userID: String, familyID: String, email: String, auth: String) {
        let keyAccess = "google"
        let values: [String: String] = [userID: "user", familyID: "family", email: "email", keyAccess: "auth"]
        values.map({ value in UserDefaults.standard.setValue(value.value, forKey: value.key) })
        MyKeychainWrapper.writeToKeychain()
        UserDefaults.standard.set(true, forKey: "hasFamilyKey")
        UserDefaults.standard.synchronize()
    }
}

extension WelcomeViewController: GIDSignInUIDelegate {
    func configureGoogleButton() {
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.colorScheme = .light
        googleSignInButton.style = .wide
        self.view.addSubview(googleSignInButton)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        googleSignInButton.topAnchor.constraint(equalTo: signIn.bottomAnchor, constant: 12).isActive = true
        view.layoutIfNeeded()
    }
}
