//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import CoreData

class MemeDetailViewController: UIViewController, MemeEditorDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    // MARK: Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
        imageView.image = UIImage(data: meme.memeImage)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditMeme" {
            let navController = segue.destinationViewController as! UINavigationController
            let memeEditor = navController.viewControllers.first as! MemeEditorViewController
            memeEditor.delegate = self
            
            memeEditor.meme = meme
        }
    }
    
    func memeDidGetCreated(topText: String?, bottomText: String?, originalImage: NSData, memeImage: NSData) {
        
        let dictionary: [String: AnyObject] = [
            Meme.Keys.TopText: topText ?? "",
            Meme.Keys.BottomText: bottomText ?? "",
            Meme.Keys.OriginalImage: originalImage,
            Meme.Keys.MemeImage: memeImage
        ]
        
        let _ = Meme(dictionary: dictionary, context: sharedContext)
        
        // Save commits onto core data
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
