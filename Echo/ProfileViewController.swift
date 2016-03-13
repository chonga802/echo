//
//  ProfileViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/5/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {
    let DESCRIPTION_PLACEHOLDER = "Add a description"
    
    private var user: User?
    private var profileUser: PFUser?
    private var isMyProfile: Bool?
    private var isTeacher: String?

    var entries: [PFObject] = []

    @IBOutlet weak var videosCollectionView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func addFavorite(sender: AnyObject) {
        if let currentUser = PFUser.currentUser() {
            if let user = self.user {
                let id = user.facebook_id!
                if let favorite_teachers = currentUser["favorite_teachers"] {
                    var array = favorite_teachers as! Array<String>
                    if !array.contains(id) {
                        array.append(id)
                        currentUser["favorite_teachers"] = array
                    }
                } else {
                    let array = [id]
                    currentUser["favorite_teachers"] = array
                }
                currentUser.saveInBackground()
            }
        }
    }
    
    func setProfile(user: PFUser?) {
        self.profileUser = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pfUser = self.profileUser {
            user = User(user: pfUser)
            isMyProfile = false
            isTeacher = pfUser["is_teacher"] as? String
        } else {
            self.profileUser = PFUser.currentUser()
            user = User(user: self.profileUser!)
            isMyProfile = true
            isTeacher = self.profileUser!["is_teacher"] as? String
        }
        
        if let user = self.user {
            self.nameLabel.text = user.username!
            self.locationLabel.text = "San Francisco, CA"
            if let desc = self.profileUser!["description"] {
                self.descriptionTextView.text = desc as? String
            }
            
            if let profImage = user.profilePhotoUrl {
                if let url  = NSURL(string: profImage),
                    data = NSData(contentsOfURL: url)
                {
                    self.profilePhoto.image = UIImage(data: data)
                }
                //self.profilePhoto.setImageWithURL(NSURL(string: profImage)!)
            }
            if let coverImage = user.coverPhotoUrl {
                if let url  = NSURL(string: coverImage),
                    data = NSData(contentsOfURL: url)
                {
                    self.coverPhoto.image = UIImage(data: data)
                }
                //self.coverPhoto.setImageWithURL(NSURL(string: coverImage)!)
            }
            
            if isMyProfile! == true || isTeacher! == "false" {
                favoriteButton.hidden = true
            }
            
//            self.favoriteButton.setImage(UIImage(named: "add-favorite") as UIImage?, forState: .Normal)
//            self.favoriteButton.setImage(UIImage(named: "added-favorite") as UIImage?, forState: .Selected)
        }
        
        //if my profile, text view styling and make text view editable
        if isMyProfile == true {
            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            descriptionTextView.layer.borderWidth = 0.5
            descriptionTextView.layer.borderColor = borderColor.CGColor
            descriptionTextView.layer.cornerRadius = 5.0
            self.descriptionTextView.delegate = self
            if self.profileUser!["description"] == nil {
                applyPlaceholderStyle(self.descriptionTextView, placeholderText: DESCRIPTION_PLACEHOLDER)
            }
        } else {
            descriptionTextView.userInteractionEnabled = false
        }
        
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        fetchEntries()
    }
    
    
    // MARK: Text View
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Save text to user description
        if let currentUser = self.profileUser {
            currentUser["description"] = textView.text
            currentUser.saveInBackground()
        }
        
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == descriptionTextView && textView.text == DESCRIPTION_PLACEHOLDER
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: DESCRIPTION_PLACEHOLDER)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == descriptionTextView && aTextView.text == DESCRIPTION_PLACEHOLDER
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
    }
    
    // MARK: Entries
    
    func fetchEntries(){
        // Define query for entires for user and NOT private
        let userId     = self.profileUser?.objectId as String!
        let predicate  = NSPredicate(format:"user_id = '\(userId)' AND private = false ")
        let entryQuery = PFQuery(className:"Entry", predicate: predicate)

        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.entries.append(object)
                    }
                }
                self.videosCollectionView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    // MARK: Collection View

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.entries.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = videosCollectionView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell

        let entry = self.entries[indexPath.row]
        cell.entry = entry

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = videosCollectionView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell
        performSegueWithIdentifier("profileToEntry", sender: cell)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "profileToEntry":
                    let cell = sender as! EntryCollectionViewCell
                    if let indexPath = self.videosCollectionView.indexPathForCell(cell) {
                        let nc = segue.destinationViewController as! UINavigationController
                        let vc = nc.topViewController as! EntryViewController
                        vc.updateEntry(self.entries[indexPath.row])
                    }
                    
                default:
                    return
            }
        }
    }
    

}