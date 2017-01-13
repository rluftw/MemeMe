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
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpMemeLabels(_ topString: String, bottomString: String) {
        setStringValueForMemeLabels(topString, label: topLabel)
        setStringValueForMemeLabels(bottomString, label: bottomLabel)
    }
    
    func setStringValueForMemeLabels(_ string: String, label: UILabel) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 17)!,
            NSStrokeWidthAttributeName: -3.0
        ] as [String : Any]
        
        if string != "" {
            label.textAlignment = .center
            label.attributedText = NSAttributedString(string: string , attributes: memeTextAttributes)
        }
    }
    
}
