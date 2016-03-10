//
//  FeedbackRequestViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class FeedbackRequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser: PFUser?
    var teachers: [PFObject] = []
    var entry: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        currentUser = PFUser.currentUser()
        
        let teacher_ids = currentUser!.objectForKey("favorite_teachers") as! NSArray
        
        // TODO: Find better way to reload tableView
        for id in teacher_ids {
            let query = PFUser.query()!
            query.whereKey("facebook_id", equalTo: id)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            self.teachers.append(object)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFeedbackEntry(entry: PFObject?) {
        self.entry = entry
    }
    
    func sendFeedbackRequest(teacher: PFObject) {
        var request: [String: String]! = Dictionary<String,String>()
        
        request["entry_id"] = self.entry?.objectId
        request["request_body"] = "Hi please help me"
        let teacherId = teacher["facebook_id"] as? String
        request["teacher_id"] = teacherId
        request["user_id"] = currentUser!["facebook_id"] as? String
        request["accepted"] = "false"
        request["resolved"] = "false"
        
        // add to requests_sent array for current user
        if let requests_sent = currentUser!["requests_sent"] {
            var array = requests_sent as! Array<Dictionary<String,String>>
            array.append(request)
            currentUser!["requests_sent"] = array
        } else {
            let array = [request]
            currentUser!["requests_sent"] = array
        }
        currentUser!.saveInBackground()
        
        // add to requests_received array for current user
        let query = PFUser.query()!
        query.whereKey("facebook_id", equalTo: teacherId!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let teacher = object as! PFUser
                        if let requests_received = teacher["requests_received"] {
                            var array = requests_received as! Array<Dictionary<String,String>>
                            array.append(request)
                            teacher["requests_received"] = array
                        } else {
                            let array = [request]
                            teacher["requests_received"] = array
                        }
                        teacher.saveInBackground()
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.teachers.count > 0 {
            return self.teachers.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TeacherFeedbackCell", forIndexPath: indexPath) as! TeacherFeedbackCell
        if self.teachers.count > 0 {
            cell.teacherName.text = self.teachers[indexPath.row]["username"] as? String
        } else {
            cell.teacherName.text = "Please add some favorite teachers"
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.teachers.count > 0 {
            performSegueWithIdentifier("feedbackSentSegue", sender: self)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "feedbackSentSegue":
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        let vc = segue.destinationViewController as! FeedbackRequestSentViewController
                        vc.setTeacher(self.teachers[indexPath.row])
                        sendFeedbackRequest(self.teachers[indexPath.row])
                    }
                    
                default:
                    return
            }
        }
        
    }
    

}
