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
    
    var blockOperations: [BlockOperation]!
    
    // Lazy fetchedResultsController
    // Stores data
    // Notifies controller when there's changes
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        let request = Meme.fetchRequest()
        request.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Tab bar hidden when previewing image
        tabBarController?.tabBar.isHidden = false
        
        // Refresh collection view
        collectionView?.reloadData()
    }
    
    
    // MARK: Laying out the collection cells
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Depending on the side of the width, the cell dimensions will change
        let dimension = view.frame.size.width <= view.frame.size.height ? (view.frame.size.width-(2*space))/3.0: (view.frame.size.width-(5*space))/6.0
        
        return CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // This triggers a layout update
        flowLayout?.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionCellView
        let meme = fetchedResultsController.object(at: indexPath) as! Meme
        let topText = meme.topText != nil ? meme.topText!: ""
        let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
        
        // Configure the cell
        cell.setUpMemeLabels(topText, bottomString: bottomText)
        cell.imageView.image = UIImage(data: meme.originalImage)
        
        return cell
    }
    
    // MARK: Navigation methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMemeDetailCollection" {
            let detailVC = segue.destination as! MemeDetailViewController
            let sender = sender as! MemeCollectionCellView
            
            let indexPath = collectionView!.indexPath(for: sender)!
            detailVC.meme = fetchedResultsController.object(at: indexPath) as! Meme
        } else if segue.identifier == "ShowMemeEditor" {
            let editorVC = (segue.destination as! UINavigationController).topViewController as! MemeEditorViewController
            
            editorVC.delegate = self
        }
    }
    
    // MARK: - MemeEditorDelegate methods
    
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
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations = [BlockOperation]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete: blockOperations.append(BlockOperation(block: { () -> Void in
            (self.collectionView?.deleteItems(at: [indexPath!]))!
        }))
        case .insert: blockOperations.append(BlockOperation(block: { () -> Void in
            self.collectionView?.insertItems(at: [newIndexPath!])
        }))
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({ () -> Void in
            for operation in self.blockOperations {
                operation.start()
            }
            }, completion: { (completed) -> Void in
                self.blockOperations = nil
        })

    }
}
