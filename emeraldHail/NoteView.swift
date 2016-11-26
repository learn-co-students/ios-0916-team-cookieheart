//
//  NoteView.swift
//  emeraldHail
//
//  Created by Henry Ly on 11/26/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class NoteView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    
    var post: Post! {
        didSet {
            noteLabel.text = post.note
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("NoteView", owner: self, options: nil)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        
        contentView.backgroundColor = UIColor.getRandomColor()
        
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }


}
