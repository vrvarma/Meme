//
//  MemeDetailViewController.swift
//  Meme
//
//  Created by Vikas Varma on 5/27/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import UIKit
class MemeDetailViewController: UIViewController {
    
    
    @IBOutlet weak var memeDetailView: UIImageView!
    
    //The meme we need to display
    var meme: Meme!
    var index: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //meme struct has the generated image.
        meme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes[index!]
        memeDetailView.image = meme.memedImage
    }
    
    //edit meme
    @IBAction func editMeme(sender: UIButton) {
        
       let controller =
        storyboard!.instantiateViewControllerWithIdentifier("memeEditor") as! MemeEditorViewController
        controller.savedMeme = meme
        controller.indexRow = index
        navigationController!.presentViewController(controller, animated: true,completion:{
            
            //Once the editing is complete
            //refresh the detailView window with the latest meme image.
            var meme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes[self.index!]
            self.memeDetailView.image = meme.memedImage
        })
        
    }

    
    @IBAction func deleteMeme(sender: AnyObject) {
        
        var confirm = buildAlertDialog(index!)
        navigationController!.presentViewController(confirm, animated: true,completion:nil)
    }
    
    //Add the dialog to confirm deletion
    func buildAlertDialog(index: Int) -> UIAlertController{
        
        var confirm = UIAlertController(title: "Delete Meme?", message: "Do you really want to delete?", preferredStyle: UIAlertControllerStyle.Alert)
        
        //No button just closes the dialog
        confirm.addAction(UIAlertAction(title: "No",style: UIAlertActionStyle.Cancel, handler: nil))
        
        //Yes button
        confirm.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler:{
            
            //If action is yes, then delete the selected meme and go back the previous screen
            action in (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(index)
            self.navigationController!.popViewControllerAnimated(true)
        }))
        return confirm
    }
    
    
}
