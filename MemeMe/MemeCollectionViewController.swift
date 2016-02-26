//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "CustomMemeCell"

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, MemeEditorDelegate  {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var blockOperations: [NSBlockOperation]!
    
    // Lazy fetchedResultsController
    // Stores data
    // Notifies controller when there's changes
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: "Meme")
        request.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var sharedContext: NSManagedObjectContext!
    
    let space: CGFloat = 3.0
    
    // MARK: Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        
        sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Tab bar hidden when previewing image
        tabBarController?.tabBar.hidden = false
        
        // Refresh collection view
        collectionView?.reloadData()
    }
    
    
    // MARK: Laying out the collection cells
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Depending on the side of the width, the cell dimensions will change
        let dimension = view.frame.size.width <= view.frame.size.height ? (view.frame.size.width-(2*space))/3.0: (view.frame.size.width-(5*space))/6.0
        
        return CGSizeMake(dimension, dimension)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // This triggers a layout update
        flowLayout?.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource methods
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionCellView
        let meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        let topText = meme.topText != nil ? meme.topText!: ""
        let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
        
        // Configure the cell
        cell.setUpMemeLabels(topText, bottomString: bottomText)
        cell.imageView.image = UIImage(data: meme.originalImage)
        
        return cell
    }
    
    // MARK: Navigation methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMemeDetailCollection" {
            let detailVC = segue.destinationViewController as! MemeDetailViewController
            let sender = sender as! MemeCollectionCellView
            
            let indexPath = collectionView!.indexPathForCell(sender)!
            detailVC.meme = fetchedResultsController.objectAtIndexPath(indexPath) as! Meme
        } else if segue.identifier == "ShowMemeEditor" {
            let editorVC = (segue.destinationViewController as! UINavigationController).topViewController as! MemeEditorViewController
            
            editorVC.delegate = self
        }
    }
    
    // MARK: - MemeEditorDelegate methods
    
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
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations = [NSBlockOperation]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete: blockOperations.append(NSBlockOperation(block: { () -> Void in
            (self.collectionView?.deleteItemsAtIndexPaths([indexPath!]))!
        }))
        case .Insert: blockOperations.append(NSBlockOperation(block: { () -> Void in
            self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
        }))
        default: break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({ () -> Void in
            for operation in self.blockOperations {
                operation.start()
            }
            }, completion: { (completed) -> Void in
                self.blockOperations = nil
        })

    }
}