//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import CoreData

class MemeTableViewController: UITableViewController {

    var memes: [Meme]!
    var sharedContext: NSManagedObjectContext!
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve the context
        sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        // Fetch the memes everything this controller is displayed
        memes = fetchAllMemes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = false
        
        // Fetch the memes everything this controller is displayed
        memes = fetchAllMemes()
        
        
        // Reload the table
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomMemeCell", forIndexPath: indexPath) as! MemeTableViewCell
        
        let meme = memes[indexPath.row]
        
        let topText = meme.topText != nil ? meme.topText!: ""
        let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
        
        cell.setUpMemeLabels(topText, bottomString: bottomText)
        cell.customImageView.image = UIImage(data: meme.originalImage)
        cell.descriptionLabel.text = "\(topText)...\(bottomText)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Remove from the model
            memes.removeAtIndex(indexPath.row)
            
            // Remove from core data
            sharedContext.deleteObject(memes[indexPath.row])
            
            // Save the commit
            CoreDataStackManager.sharedInstance().saveContext()
            
            tableView.reloadData()
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
            
            let indexPath = tableView?.indexPathForCell(sender)
            detailVC.meme = memes[indexPath!.row]
        }
    }
    
    // MARK: - CoreData
    func fetchAllMemes() -> [Meme] {
        let fetch = NSFetchRequest(entityName: "Meme")
        
        do {
            return try self.sharedContext.executeFetchRequest(fetch) as! [Meme]
        } catch {
            return [Meme]()
        }
    }
}
