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

    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let request = Meme.fetchRequest()
        request.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let memes = fetchedResultsController.sections![section]
    
        return memes.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMemeCell", for: indexPath) as! MemeTableViewCell
        
        let meme = fetchedResultsController.object(at: indexPath) as! Meme
        
        let topText = meme.topText != nil ? meme.topText!: ""
        let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
        
        cell.setUpMemeLabels(topText, bottomString: bottomText)
        cell.customImageView.image = UIImage(data: meme.originalImage)
        cell.descriptionLabel.text = "\(topText)...\(bottomText)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Fetch the data at that indexPath
            let meme = fetchedResultsController.object(at: indexPath) as! Meme
            
            // Remove from core data
            sharedContext.delete(meme)
            
            // Save the commit
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMemeDetailFromTable" {
            let detailVC = segue.destination as! MemeDetailViewController
            let sender = sender as! MemeTableViewCell
            
            let indexPath = tableView!.indexPath(for: sender)!
            detailVC.meme = fetchedResultsController.object(at: indexPath) as! Meme
        } else if segue.identifier == "ShowMemeEditor" {
            let editorVC = (segue.destination as! UINavigationController).topViewController as! MemeEditorViewController
            
            editorVC.delegate = self
        }
    }
    
    // MARK: - FetchedResultsControllerDelegate methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete: tableView.deleteRows(at: [indexPath!], with: .fade)
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .fade)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - MemeEditorDelegate
    
    
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
