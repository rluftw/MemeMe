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
    @NSManaged var originalImage: NSData
    @NSManaged var memeImage: NSData
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(topText: String?, bottomText: String?, originalImage: NSData, memeImage: NSData, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Meme", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memeImage = memeImage
    }
    
    
    
}