//
//  MemeTableViewController.swift
//  Meme
//
//  Created by Vikas Varma on 5/24/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet var memeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //if the global meme list is empty
        //Then instantiate memeEditor.
        if (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count == 0 {
            
            //Pop up the editor
            let controller =
            self.storyboard!.instantiateViewControllerWithIdentifier("memeEditor") as! MemeEditorViewController
            self.navigationController!.presentViewController(controller, animated: true, completion: nil)
        }
        //Reload meme data
        memeTableView.reloadData()
    }
    //Table view functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        
        //Show the selected meme in a Detail View
        let memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        let meme = memes[indexPath.row]
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        controller.index = indexPath.row
    
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell", forIndexPath: indexPath) as! MemeTableViewCell
        
        //Grab the entry for each row
        let meme = memes[indexPath.row]
        
        // Configure the cell and populate the imageView and text fields.
        cell.memeImage.image = meme.memedImage
        cell.topText.text = meme.topText
        cell.bottomText.text = meme.bottomText
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //println(editingStyle)
        if editingStyle == .Delete {
            
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    @IBAction func addMeme(sender: UIBarButtonItem) {
        
        let controller =
        self.storyboard!.instantiateViewControllerWithIdentifier("memeEditor") as! MemeEditorViewController
        
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func setEditMode(sender: UIBarButtonItem) {
        
        //println(memeTableView.editing)
        
        if memeTableView.editing{
            
            //We're in edit mode
            //Set the tableView to non-edit mode
            memeTableView
                .setEditing(false, animated: true)
            sender.style = UIBarButtonItemStyle.Plain
            sender.title = "Edit"
        }
        else{
            //set the tableView to edit mode
            //change the item's title
            memeTableView.setEditing(true, animated: true)
            sender.title = "Done"
            sender.style = UIBarButtonItemStyle.Done
        }
    }
}