//
//  MemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/5/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit



class MemeCollectionCellView: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
