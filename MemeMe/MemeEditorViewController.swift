//
//  ViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/4/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let textfieldDelegate = TextFieldDelegate()
    var meme: Meme!
    
    // MARK: - Viewcontroller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reset()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboard()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboard()
    }
    
    // MARK: - UIImagePickerController delegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imageView.image = image
        
        // Enable Share button
        shareButton.enabled = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - IBAction methods
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        pickImageFromSource(.Camera)
    }
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        pickImageFromSource(.SavedPhotosAlbum)
    }
    
    @IBAction func share(sender: AnyObject) {
        let memeImage = generateMeme()
        
        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> Void in
            if completed { self.save(memeImage) }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        reset()
    }
    
    // MARK: - Helper methods
    
    
    // Set properties to default such as text/image
    func reset() {
        setupTextField(topTextField, text: "TOP")
        setupTextField(bottomTextField, text: "BOTTOM")
        
        imageView.image = nil
        shareButton.enabled = false
    }
    
    func setupTextField(textfield: UITextField, text: String) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        textfield.text = text
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .Center
        textfield.delegate = textfieldDelegate
    }
    
    func pickImageFromSource(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func generateMeme() -> UIImage {
        // Hiding the navbar and toolbar
        barsHidden(true)
        
        // Create the meme
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the navbar and toolbar back again
        barsHidden(false)
        
        return memeImage
    }
    
    func subscribeToKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboard() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y -= bottomTextField.isFirstResponder() ? getKeyboardHeight(notification): 0
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y += bottomTextField.isFirstResponder() ? getKeyboardHeight(notification): 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userinfo = notification.userInfo!
        let keyboardSize = userinfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func barsHidden(hidden: Bool) {
        navigationController?.navigationBarHidden = hidden
        navigationController?.toolbarHidden = hidden
    }
    
    func save(memeImage: UIImage) {
        meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: imageView.image!, memeImage: memeImage)
    }
}

