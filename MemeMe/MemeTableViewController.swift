//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {

    var memes: [Meme] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memes
    }
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = false
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.customImageView.image = meme.originalImage
        cell.descriptionLabel.text = "\(topText)...\(bottomText)"
        
        return cell
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
}
