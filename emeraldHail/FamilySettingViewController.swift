//
//  FamilySettingViewController.swift
//  emeraldHail
//
//  Created by Enrique Torrendell on 11/23/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import CoreData
import MessageUI
import Branch

class FamilySettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var touchID: UISegmentedControl!
    @IBOutlet weak var joinFamily: JoinFamily!
    
    // MARK: - Properties
    
    let store = DataStore.sharedInstance
    let database = FIRDatabase.database().reference()
    
    // MARK: - Loads
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkTouchID()
    }
    
    // MARK: - Actions
    
    @IBAction func changeFamilyPic(_ sender: UIButton) {
        handleSelectProfileImageView()
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            store.clearDataStore()
            
            NotificationCenter.default.post(name: .openWelcomeVC, object: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    @IBAction func touchIDOnOff(_ sender: UISegmentedControl) {
        
        if touchID.selectedSegmentIndex == 0 {
            
            touchID(activate: false)
            deleteAllData(entity: "CurrentUser")
            
        }
            
        else if touchID.selectedSegmentIndex == 1 {
            
            touchID(activate: true)
            saveDataToCoreData()
            
        }
    }
    
    @IBAction func sendEmail(_ sender: UIButton) {
        sendEmail()
    }
    
    @IBAction func joinFamily(_ sender: UIButton) {
        
        if joinFamily.isHidden == true {
            joinFamily.isHidden = false
        } else {
            joinFamily.isHidden = true
            
        }
    }
    
    @IBAction func didPressInviteParent(_ sender: UIButton) {
        print("didPressInviteParent pressed")
        
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "123123123")
        
        let newLinkProperties: BranchLinkProperties = BranchLinkProperties()
        newLinkProperties.feature = "invite"
        newLinkProperties.channel = "SMS"
        newLinkProperties.addControlParam("$ios_url", withValue: "docit://")
        newLinkProperties.addControlParam("inviteFamilyID", withValue: store.user.familyId)
        
        //        branchUniversalObject.getShortUrl(with: newLinkProperties) { (url, error) in
        //            if error == nil {
        //                print("2. got my Branch link to share: \(url)")
        //            }
        //        }
        
        branchUniversalObject.showShareSheet(with: newLinkProperties, andShareText: "Please join my family on Doc It!", from: self) { (activityType, completed) in
            print("done showing share sheet!")
        }
        
        print(branchUniversalObject)
        
    }
    
    // MARK: - Methods
    
    func changeFamilyCoverPic(photo: UIImage, handler: @escaping (Bool) -> Void) {
        
        let familyDatabase = database.child(Constants.Database.family).child(store.user.familyId)
        let storageRef = FIRStorage.storage().reference(forURL: "gs://emerald-860cb.appspot.com")
        let storeImageRef = storageRef.child(Constants.Storage.familyImages).child(store.user.familyId)
        
        guard let uploadData = UIImageJPEGRepresentation(photo, 0.25) else { return }
        
        storeImageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error in changeFamilyCoverPic")
                
                return
            }
            
            guard let familyPicString = metadata?.downloadURL()?.absoluteString else { return }
            
            familyDatabase.updateChildValues(["coverImageStr": familyPicString], withCompletionBlock: { (error, dataRef) in
                
                DispatchQueue.main.async {
                    
                    handler(true)
                }
            })
        })
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
        
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImageFromPicker = editImage
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            changeFamilyCoverPic(photo: selectedImage, handler: { success in
                
                self.dismiss(animated: true, completion: nil)
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picked canceled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["thedocitapp@gmail.com"])
            mail.setSubject("Feedback")
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // Mark: Methods Touch ID
    
    func checkTouchID() {
        
        
        let database = FIRDatabase.database().reference().child(Constants.Database.settings).child(store.user.familyId).child("touchID")
        
        database.observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as? Bool
            
            if value == true {
                
                self.touchID.selectedSegmentIndex = 1
                
            }
                
            else if value == false {
                
                self.touchID.selectedSegmentIndex = 0
            }
            
        })
        
    }
    
    func touchID(activate: Bool) {
        
        FIRDatabase.database().reference().child(Constants.Database.settings).child(store.user.familyId).child("touchID").setValue(activate)
        
        
    }
    
    func saveDataToCoreData() {
        
        deleteAllData(entity: "CurrentUser")
        
        let managedContext = store.persistentContainer.viewContext
        
        let familyCoreData = CurrentUser(context: managedContext)
        
        familyCoreData.familyID = DataStore.sharedInstance.user.familyId
        
        do {
            
            try managedContext.save()
            print("I just save the family ID in Core Data")
            
        } catch {
            
            print("error")
        }
    }
    
    func deleteAllData(entity: String)
    {
        let managedContext = store.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
}
