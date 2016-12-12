//
//  PainLevelViewController.swift
//  emeraldHail
//
//  Created by Luna An on 11/17/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Firebase

class PainLevelViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Outlets 
    
    @IBOutlet weak var painLevelCollectionView: UICollectionView!
    @IBOutlet weak var painView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!

    
    // MARK: - Properties
    
    var noPain: PainLevel = .noPain
    var mild:PainLevel = .mild
    var moderate:PainLevel = .moderate
    var severe: PainLevel = .severe
    var verySevere: PainLevel = .verySevere
    var excruciating: PainLevel = .excruciating
    
    var painLevels = [PainLevel]()
    let storage = FIRStorage.storage().reference(forURL: "gs://emerald-860cb.appspot.com")
    var selectedPainLevel: PainLevel?
    
    let postRef : FIRDatabaseReference = FIRDatabase.database().reference().child("posts")
    
    let store = DataStore.sharedInstance
    
    
       // MARK: - Loads

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "Pain Level"
        painLevelCollectionView.allowsMultipleSelection = false
        
        painLevels = [noPain, mild, moderate, severe, verySevere, excruciating]
        
        setupView()
        
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: UIButton) {
        
            addPainLevel()
            saveButton.isEnabled = false
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Methods

    func setupView() {
        
        postTitleLabel.text = "How does \(store.member.firstName) feel?"
        
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)
        
        painView.layer.cornerRadius = 10
        painView.layer.borderColor = Constants.Colors.submarine.cgColor
        painView.layer.borderWidth = 1

//        painLevelCollectionView.tintColor = UIColor.darkGray
    
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return painLevels.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PainLevelCollectionViewCell
        
        cell.painLevelImage.image = painLevels[indexPath.row].image
        cell.painLevelDescription.text = painLevels[indexPath.row].description
        
        if cell.isSelected == true {
//            cell.wasSelected()
            cell.backgroundColor = Constants.Colors.submarine
        }
        else if cell.isSelected == false {
//            cell.wasDeselected()
            cell.backgroundColor = UIColor.clear
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PainLevelCollectionViewCell else { return }
        selectedPainLevel = painLevels[indexPath.row]
//        cell.wasSelected()
        
        cell.backgroundColor = Constants.Colors.submarine
        cell.layer.cornerRadius = 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PainLevelCollectionViewCell else { return }
//        cell.wasDeselected()
        
        cell.backgroundColor = UIColor.clear
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    func addPainLevel(){
        
        guard let painLevelDescription = selectedPainLevel?.description else { return }
        
        //let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss a"
        //let timestamp = dateFormatter.string(from: currentDate)
        
        // uniqueID added
        
        let databasePostContentRef = postRef.child(store.eventID).childByAutoId()
        let uniqueID = databasePostContentRef.key
        
        let newPain = Pain(content: painLevelDescription, timestamp: getTimestamp(), uniqueID: uniqueID)
        
        databasePostContentRef.setValue(newPain.serialize(), withCompletionBlock: {error, ref in
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
}
