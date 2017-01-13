//
//  ViewController.swift
//  MemeMe
//
//  Created by Xing Hui Lu on 2/4/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import CoreData

protocol MemeEditorDelegate: class {
    func memeDidGetCreated(_ topText: String?, bottomText: String?, originalImage: Data, memeImage: Data)
}

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
    weak var delegate: MemeEditorDelegate?
    
    // MARK: - Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reset()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // If there was a meme passed in, layout the fields
        if let _ = meme {
            shareButton.isEnabled = true
            
            let topText = meme.topText != nil ? meme.topText!: ""
            let bottomText = meme.bottomText != nil ? meme.bottomText!: ""
            
            setupTextField(topTextField, text: topText)
            setupTextField(bottomTextField, text: bottomText)
            
            imageView.image = UIImage(data: meme.originalImage as Data)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboard()
    }
    
    // MARK: - UIImagePickerController delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imageView.image = image
        
        // Enable Share button
        shareButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - IBAction methods
    
    @IBAction func pickImageFromCamera(_ sender: AnyObject) {
        pickImageFromSource(.camera)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: AnyObject) {
        pickImageFromSource(.savedPhotosAlbum)
    }
    
    @IBAction func share(_ sender: AnyObject) {
        let memeImage = generateMeme()
        
        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (type, completed, returnedItems, error) -> Void in
            if completed {
                print("Image getting saved")
                
                self.save(memeImage)
                
                // dismiss the activity controller
                self.dismiss(animated: true, completion: nil)
                
                // pop to the root viewcontroller
                _ = self.navigationController?.popToRootViewController(animated: false)
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    
    
    // Set properties to default such as text/image
    func reset() {
        setupTextField(topTextField, text: "TOP")
        setupTextField(bottomTextField, text: "BOTTOM")
        
        imageView.image = nil
        shareButton.isEnabled = false
    }
    
    func setupTextField(_ textfield: UITextField, text: String) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ] as [String : Any]
        
        textfield.text = text
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .center
        textfield.delegate = textfieldDelegate
    }
    
    func pickImageFromSource(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func generateMeme() -> UIImage {
        // Hiding the navbar and toolbar
        barsHidden(true)
        
        // Create the meme
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the navbar and toolbar back again
        barsHidden(false)
        
        return memeImage!
    }
    
    func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboard() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = bottomTextField.isFirstResponder ? -1 * getKeyboardHeight(notification): 0
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y += bottomTextField.isFirstResponder ? getKeyboardHeight(notification): 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userinfo = notification.userInfo!
        let keyboardSize = userinfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func barsHidden(_ hidden: Bool) {
        navigationController?.isNavigationBarHidden = hidden
        navigationController?.isToolbarHidden = hidden
    }
    
    func save(_ memeImage: UIImage) {
        let originalImageData = UIImageJPEGRepresentation(imageView.image!, 1)!
        let memeImageData = UIImageJPEGRepresentation(memeImage, 1)!
        
        delegate?.memeDidGetCreated(topTextField.text, bottomText: bottomTextField.text, originalImage: originalImageData, memeImage: memeImageData)
    }
}

