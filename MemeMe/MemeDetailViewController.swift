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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        imageView.image = UIImage(data: meme.memeImage as Data)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditMeme" {
            let navController = segue.destination as! UINavigationController
            let memeEditor = navController.viewControllers.first as! MemeEditorViewController
            memeEditor.delegate = self
            
            memeEditor.meme = meme
        }
    }
    
    func memeDidGetCreated(_ topText: String?, bottomText: String?, originalImage: Data, memeImage: Data) {
        
        let dictionary: [String: AnyObject] = [
            Meme.Keys.TopText: topText as AnyObject? ?? "" as AnyObject,
            Meme.Keys.BottomText: bottomText as AnyObject? ?? "" as AnyObject,
            Meme.Keys.OriginalImage: originalImage as AnyObject,
            Meme.Keys.MemeImage: memeImage as AnyObject
        ]
        
        let _ = Meme(dictionary: dictionary, context: sharedContext)
        
        // Save commits onto core data
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
