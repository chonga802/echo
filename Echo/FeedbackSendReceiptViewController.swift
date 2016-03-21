//
//  FeedbackSendReceiptViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/20/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class FeedbackSendReceiptViewController: UIViewController {
    var studentName : String?

    @IBOutlet weak var studentNameLabel: UILabel!

    func navigateToInbox(){
        let storyboard = UIStoryboard(name: "Inbox", bundle: nil)
        let vc  = storyboard.instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentNameLabel.text = "\(studentName!)."
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "navigateToInbox", userInfo: nil, repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}