//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
        
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpMemeLabels(topString: String, bottomString: String) {
        setStringValueForMemeLabels(topString, label: topLabel)
        setStringValueForMemeLabels(bottomString, label: bottomLabel)
    }
    
    func setStringValueForMemeLabels(string: String, label: UILabel) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 17)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        if string != "" {
            label.textAlignment = .Center
            label.attributedText = NSAttributedString(string: string , attributes: memeTextAttributes)
        }
    }
    
}
