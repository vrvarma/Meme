//
//  MemeEditorViewController.swift
//  Meme
//
//  Created by Vikas Varma on 5/24/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UITextFieldDelegate {
    
    
    @IBOutlet weak var topToolBar: UIToolbar!
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var shareMemeButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var savedMeme: Meme!
    var indexRow: Int!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //If this controller is invoked for an already saved Meme
        //Set it in edit mode
        if let tempMeme = savedMeme {
            
            topTextField.text = tempMeme.topText
            bottomTextField.text = tempMeme.bottomText
            imageView.image = tempMeme.image
            shareMemeButton.enabled = true
        }
        
    }
    
    override func viewWillAppear(animated:Bool) {
        
        super.viewWillAppear(animated)
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        //println("count \((UIApplication.sharedApplication().delegate as! AppDelegate).memes.count)")
        if (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count == 0 {
            
            cancelButton.enabled = false
        }
        else{
            
            cancelButton.enabled = true
        }
        
        //enable shareMemeButton if and only if there's an image in the view
        //println(imageView.image)
        if imageView.image == nil{
            
            shareMemeButton.enabled = false
        }
        else {
            
            shareMemeButton.enabled = true
        }
        
        
        //Set the default text attributes
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        //center the text
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
                
        //Disable camera button if its on a simulator
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        //unsubscribe from keyboard notifications
        unsubscribeFromKeyboardNotifications()
    }
    
    //action method to pick an image from the album
    @IBAction func pickFromAlbum(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //action method to pick an image from the camera
    //if its on a real device
    @IBAction func pickFromCamera(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //image picker controller methods.
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
            if let image = info[UIImagePickerControllerOriginalImage]  as?  UIImage {
                
                imageView.image = image
                dismissViewControllerAnimated(true, completion: nil)
            }
    }
    
    //Subscribe to keyboard notifications.
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification,
            object: nil)
        
    }
    
    //Unsubscribe from keyboard notifications
    //called when the controller exits.
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
        
    }
    
    //Keyboard functions.
    //slide the picture up, to show the keyboard
    func keyboardWillShow(notification: NSNotification) {
        
        if bottomTextField.isFirstResponder() {
            
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //slide back the keyboard, when the user is done editing
    func keyboardWillDisappear(notification: NSNotification){
        
        if bottomTextField.isFirstResponder() {
            
            view.frame.origin.y = 0
        }
    }
    
    //method to calculates the keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //if the user clicks on return key. 
    //Stop editing and return.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
    
    func saveMeme(memedImage: UIImage!) {
        
        var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image, memedImage: memedImage)
        //Get the AppDelegate instance
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let pem = savedMeme {
            
            //println ("updating index   \(indexRow)")
            //replace the already saved meme with the new one.
            appDelegate.memes[indexRow] = meme
            savedMeme = nil
        }else{
            
            appDelegate.memes.append(meme)
        }
        dismissViewControllerAnimated(true, completion: nil)
        //println("Number of memes saved: \(appDelegate.memes.count)")
        
    }
    
    //This will be the new sharing function
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        let memedImage: UIImage = generateMeme()
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        //add the completion handler
        activityController.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed{
                
                self.saveMeme(memedImage)
            }
        }
        //pop up the activity window.
        presentViewController(activityController, animated: true, completion: nil)
        
    }
    
    //User cancelled the editor
    @IBAction func cancelEditor(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //The actual funtion to generate the combined image
    func generateMeme() -> UIImage {
        
        var memedImage: UIImage?
        
        //Hide the tool and nav bar
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Render the view to a single image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show tool and nav bar
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        return memedImage!
    }
}

