//
//  SentViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/14/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class SentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var requestsSentTableView: UITableView!
    
    var inboxUser: PFUser?
    var requestsSent: Array<Dictionary<String,String>> = []
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        requestsSentTableView.delegate = self
        requestsSentTableView.dataSource = self
        
        fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        requestsSentTableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchRequests(){
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        do {
            try inboxUser?.fetch()
        } catch {
            print("Error fetching inbox user")
        }
        if let requests_sent = inboxUser!["requests_sent"] {
            self.requestsSent = requests_sent as! Array<Dictionary<String,String>>
        }
        requestsSentTableView.reloadData()
    }
    
    func onRefresh(){
        fetchRequests()
        self.refreshControlTableView.endRefreshing()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsSent.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentRequests", forIndexPath: indexPath) as! InboxCell

        var request = self.requestsSent[indexPath.row]
        
        if let id = request["entry_id"] {
            let entry_id = id as String
            var song = ""
            let entryQuery = PFQuery(className:"Entry")
            do {
                let entry = try entryQuery.getObjectWithId(entry_id)
                song = entry["song"] as! String
            } catch {
                print("Error getting entry from inbox")
            }
            
            let teacher_id = request["user_id"]! as String
            let teacherQuery = PFUser.query()!
            teacherQuery.whereKey("facebook_id", equalTo: teacher_id)
            teacherQuery.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    var teacher_name = ""
                    var teacher_picture = ""
                    if let objects = objects {
                        for object in objects {
                            teacher_name = object["username"] as! String
                            teacher_picture = object["profilePhotoUrl"] as! String
                        }
                    }
                    cell.inboxTextLabel.text = "Awaiting feedback on " + song + " from " + teacher_name
                    if let url  = NSURL(string: teacher_picture),
                        data = NSData(contentsOfURL: url)
                    {
                        cell.avatarImageView.image = UIImage(data: data)
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            if tableView == requestsReceivedTableView {
//                let inboxDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InboxDetailsViewController") as! InboxDetailsViewController
//    
//                let request = requestsReceived[indexPath.row]
//    
//                inboxDetailsViewController.request = request
//    
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//                self.navigationController?.pushViewController(inboxDetailsViewController, animated: true)
//            }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
//                case "inboxDetails":
//                    if let indexPath = self.tableView.indexPathForSelectedRow {
//                        let nc = segue.destinationViewController as! UINavigationController
//                        let vc = nc.topViewController as! InboxDetailsViewController
//                        vc.setFeedbackRequest(self.requestsReceived[indexPath.row])
//                    }
                
                default:
                    return
            }
        }
    }
    

}
