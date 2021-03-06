//
//  FancyInboxViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/20/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import PageMenu


class FancyInboxViewController: UIViewController {
    var pageMenu : CAPSPageMenu?
    var controllerArray : [UIViewController] = []
    let parameters: [CAPSPageMenuOption] = [
        .MenuItemSeparatorWidth(0),
        .ScrollMenuBackgroundColor(UIColor.whiteColor()),
        .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
        .BottomMenuHairlineColor(StyleGuide.Colors.echoBlue),
        .SelectionIndicatorColor(StyleGuide.Colors.echoBlue),
        .MenuMargin(20.0),
        .MenuHeight(40.0),
        .SelectedMenuItemLabelColor(StyleGuide.Colors.echoBlue),
        .UnselectedMenuItemLabelColor(StyleGuide.Colors.echoCharcoal),
        .MenuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
        .UseMenuLikeSegmentedControl(true),
        .MenuItemSeparatorRoundEdges(true),
        .SelectionIndicatorHeight(2.0),
        .MenuItemSeparatorPercentageHeight(0.1)
    ]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.tabBarController?.tabBar.hidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        self.view.addSubview(pageMenu!.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onHomePressed(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setupViewControllers() {
        let inboxVc = self.storyboard?.instantiateViewControllerWithIdentifier("InboxViewController") as! InboxViewController
        inboxVc.title = "RECEIVED"
        inboxVc.parentNavigationController = self.navigationController
        let sentVc = self.storyboard?.instantiateViewControllerWithIdentifier("SentViewController") as! SentViewController
        sentVc.title = "SENT"
        sentVc.parentNavigationController = self.navigationController
        let acceptedVc = self.storyboard?.instantiateViewControllerWithIdentifier("AcceptedRequestsViewController") as! AcceptedRequestsViewController
        acceptedVc.title = "ACCEPTED"
        acceptedVc.parentNavigationController = self.navigationController
        controllerArray.append(inboxVc)
        controllerArray.append(sentVc)
        controllerArray.append(acceptedVc)
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
