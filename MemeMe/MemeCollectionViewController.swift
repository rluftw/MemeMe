//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/6/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CustomMemeCell"

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memes
    }
    
    let space: CGFloat = 3.0
    
    // MARK: Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Tab bar hidden when previewing image
        tabBarController?.tabBar.hidden = false
        
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
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionCellView
        let meme = memes[indexPath.row]
        let topText = meme.topText != nil ? meme.topText!: ""
        let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
        
        // Configure the cell
        cell.setUpMemeLabels(topText, bottomString: bottomText)
        cell.imageView.image = meme.originalImage
    
        return cell
    }

    // MARK: Navigation methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMemeDetailFromCollection" {
            print("ShowMemeDetailFromCollection")
            
            let detailVC = segue.destinationViewController as! MemeDetailViewController            
            let sender = sender as! MemeCollectionCellView
            
            let indexPath = collectionView?.indexPathForCell(sender)
            detailVC.meme = memes[indexPath!.row]
        }
    }
}