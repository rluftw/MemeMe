//
//  Meme.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/5/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Meme: NSManagedObject {
    @NSManaged var topText: String?
    @NSManaged var bottomText: String?
    @NSManaged var originalImage: Data
    @NSManaged var memeImage: Data
    
    struct Keys {
        static let TopText = "topText"
        static let BottomText = "bottomText"
        static let OriginalImage = "originalImage"
        static let MemeImage = "memeImage"
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(topText: String?, bottomText: String?, originalImage: Data, memeImage: Data, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Meme", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memeImage = memeImage
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Meme", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.topText = dictionary[Keys.TopText] as? String
        self.bottomText = dictionary[Keys.BottomText] as? String
        self.originalImage = dictionary[Keys.OriginalImage] as! Data
        self.memeImage = dictionary[Keys.MemeImage] as! Data
    }
    
}
