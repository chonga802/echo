//
//  ExploreViewController.swift
//  Echo
//
//  Created by Andrew Yu on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AVKit
import AVFoundation
import AFNetworking

class ExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var entriesGridView: UICollectionView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    var refreshControlTableView: UIRefreshControl!

    var controller: AVPlayerViewController?

    var entries: [PFObject] = []
    
    var videoUrl: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
//        if navigationController?.viewControllers.count == 1 {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .Plain, target: self, action: "onCancel")
//            
//        }
        self.navigationController?.navigationBarHidden = false
        entriesGridView.delegate    = self
        entriesGridView.dataSource  = self
        
        // TODO: Implement Parse caching for teachers and entries, way too slow
        fetchEntries()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        entriesGridView?.insertSubview(refreshControlTableView, atIndex: 0)
        
        entriesGridView.backgroundColor = UIColor.whiteColor()

        if let entriesLayout = entriesGridView.collectionViewLayout as? UICollectionViewFlowLayout {
            entriesLayout.minimumInteritemSpacing = 1
            entriesLayout.minimumLineSpacing = 1
        }
    }
    
    func onCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onImageTap(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.coverImageView.alpha = 0.0
            self.playVideo(self.videoUrl!)
            
            }, completion: nil)
    }

    private func convertVideoDataToNSURL() {

        let query = PFQuery(className:"Videos")
        query.getObjectInBackgroundWithId("eoAhWJRrjK") {
            (Video: PFObject?, error: NSError?) -> Void in
            if error == nil && Video != nil {
                let videoData = Video!["video"] as! PFFile
                videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    self.videoUrl = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: "eoAhWJRrjK")
                })
            } else {
                print(error)
            }
        }
    }

    func fetchEntries(){
        let entryQuery = PFQuery(className:"Entry")
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.entries.append(object)
                        self.entriesGridView.reloadData()
                    }
//                    print("These are the entries")
//                    print(self.entries)
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func onRefresh(){
        print("I just got refreshed")
        
        self.refreshControlTableView.endRefreshing()
    }
    
    // MARK: Video
    private func playVideo(url: NSURL){
        
        controller = AVPlayerViewController()
        controller!.willMoveToParentViewController(self)
        addChildViewController(controller!)
        view.addSubview(controller!.view)
        controller!.didMoveToParentViewController(self)
        controller!.view.translatesAutoresizingMaskIntoConstraints = false
        controller!.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        controller!.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        controller!.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        controller!.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        controller!.view.heightAnchor.constraintEqualToAnchor(controller!.view.widthAnchor, multiplier: 1, constant: 1)
        
        
        let player = AVPlayer(URL: url)
        controller!.player = player
        controller!.player!.play()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.entries.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let kWidth = (collectionView.frame.width * 0.3333) - 1
        return CGSizeMake(kWidth, kWidth)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = entriesGridView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell
        let entry = self.entries[indexPath.row]
        cell.entry = entry
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        convertVideoDataToNSURL()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        FileProcessor.sharedInstance.deleteVideoFileWithId("eoAhWJRrjK")
        controller?.player?.pause()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "exploreToEntry":
                    let cell = sender as! EntryCollectionViewCell
                    if let indexPath = self.entriesGridView.indexPathForCell(cell) {
                        let vc = segue.destinationViewController as! EntryViewController
                        vc.entry = self.entries[indexPath.row]
                    }
                
                default:
                    return
            }
        }
    }
    

}
