//
//  AddMembersViewController.swift
//  emeraldHail
//
//  Created by Luna An on 11/21/16.
//  Copyright © 2016 Mimicatcodes. All rights reserved.
//

import UIKit
import Firebase

class AddMembersViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // OUTLETS
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var genderField: UITextField!


    // LOADS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addProfileSettings()
        hideKeyboardWhenTappedAround()
    }
    
    // ACTIONS
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = firstNameField.text, name != "",
            let lastName = lastNameField.text, lastName != "",
            let dob = birthdayField.text, dob != ""
            else { return }
        let gender = Logics.sharedInstance.genderType
        
        let database: FIRDatabaseReference = FIRDatabase.database().reference()
        let databaseMembersRef = database.child("members").child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId()
        let uniqueID = databaseMembersRef.key
        
        let storageRef = FIRStorage.storage().reference(forURL: "gs://emerald-860cb.appspot.com")
        let imageId = uniqueID
        let storageImageRef = storageRef.child("profileImages").child(imageId)
        
        if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
            storageImageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print ("ERROR!")
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let member = Member(profileImage: profileImageUrl, firstName: name, lastName: lastName, gender: gender, birthday: dob, uniqueID: uniqueID)
        
                    
                    databaseMembersRef.setValue(member.serialize(), withCompletionBlock: { error, dataRef in
                        self.dismiss(animated: true, completion: nil)
                    
                    })
                }
            
            })
        }
        
    }
    
    @IBAction func genderSegment(_ sender: UISegmentedControl) {
    
        switch sender.selectedSegmentIndex {
        case 0:
            Logics.sharedInstance.genderType = Gender.female.rawValue
        case 1:
            Logics.sharedInstance.genderType = Gender.male.rawValue
        default:
            break
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // METHODS
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboardView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboardView() {
        view.endEditing(true)
    }


    func addProfileSettings() {
        addGestureRecognizer(imageView: profileImageView)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.setRounded()
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        profileImageView.layer.borderWidth = 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool     {
        textField.resignFirstResponder()
        return false
    }
    
    func addGestureRecognizer(imageView: UIImageView){
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        self.present(picker, animated: true, completion: nil) 
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picked canceled")
        dismiss(animated: true, completion: nil)
    }

}

extension UIImageView {
    
    // METHODS
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
