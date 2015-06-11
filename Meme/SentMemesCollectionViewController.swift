//
//  SentMemesCollectionViewController.swift
//  Meme
//
//  Created by Vikas Varma on 6/3/15.
//  Copyright (c) 2015 Vikas Varma. All rights reserved.
//

import Foundation

import UIKit

class SentMemesCollectionViewController : UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var memeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Reload meme data
        memeCollectionView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Reload meme data
        memeCollectionView.reloadData()
    }
    
    //Collection view functions
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        let meme = memes[indexPath.item]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! SentMemeCollectionViewCell
        //println("Cell collection \(cell) \(meme)")
        cell.memeImage.image = meme.memedImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath){
        
        let memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        let meme = memes[indexPath.row]
        
        //if we are not editing the items then show the detail view
        if !editing{
            
            let controller = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            
            controller.index = indexPath.row
            
            navigationController?.pushViewController(controller, animated: true)
        }
        else{
            
            //Create the alert dialog
            //We're editing so show a confirmation dialog
            //and delete this meme if confirmed action is delete
            var confirm = buildAlertDialog(indexPath)
            presentViewController(confirm, animated: true, completion: nil)
        }
    }
    
    //Add a dialog to confirm
    func buildAlertDialog(indexPath:NSIndexPath) -> UIAlertController{
        
        var confirm = UIAlertController(title: "Delete Meme?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Cancel button just closes the dialog
        confirm.addAction(UIAlertAction(title: "Cancel",style: UIAlertActionStyle.Cancel, handler: nil))
        
        //Delete button
        confirm.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler:{
            //Delete the selected entry
            action in (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
            //and reload the data
            self.memeCollectionView.reloadData()
        }))
        return confirm
    }
    
    //Add a new meme from the action button
    @IBAction func addNewMeme(sender: UIBarButtonItem) {
        
        let controller = storyboard?.instantiateViewControllerWithIdentifier("memeEditor") as! MemeEditorViewController
        navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    //action method to put the collection in edit mode
    //and vice-versa
    @IBAction func setEditMode(sender: UIBarButtonItem) {
        
        //The View is in edit mode.
        //Set it back to non edit mode
        if editing{
            
            sender.style = UIBarButtonItemStyle.Plain
            sender.title = "Edit"
            editing = false
        }
        else{
            //else Set the view to edit mode
            sender.title = "Done"
            sender.style = UIBarButtonItemStyle.Done
            editing = true
        }
    }
}
