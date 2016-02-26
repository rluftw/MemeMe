//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import CoreData

class MemeTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, MemeEditorDelegate {

    // We're going to be replacing this array with fetchedResultsController
    // var memes: [Meme]!
    
    var sharedContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Meme")
        request.sortDescriptors = []
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve the context
        sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        fetchedResultsController.delegate = self
        
        // Fetch all data from core data
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = false
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let memes = fetchedResultsController.sections![section]
    
        return memes.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomMemeCell", forIndexPath: indexPath) as! MemeTableViewCell
        
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        
        let topText = meme.topText != nil ? meme.topText!: ""
        let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
        
        cell.setUpMemeLabels(topText, bottomString: bottomText)
        cell.customImageView.image = UIImage(data: meme.originalImage)
        cell.descriptionLabel.text = "\(topText)...\(bottomText)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Fetch the data at that indexPath
            let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
            
            // Remove from core data
            sharedContext.deleteObject(meme)
            
            // Save the commit
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMemeDetailFromTable" {
            let detailVC = segue.destinationViewController as! MemeDetailViewController
            let sender = sender as! MemeTableViewCell
            
            let indexPath = tableView!.indexPathForCell(sender)!
            detailVC.meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        } else if segue.identifier == "ShowMemeEditor" {
            let editorVC = (segue.destinationViewController as! UINavigationController).topViewController as! MemeEditorViewController
            
            editorVC.delegate = self
        }
    }
    
    // MARK: - FetchedResultsControllerDelegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete: tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Insert: tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default: break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - MemeEditorDelegate
    
    
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
