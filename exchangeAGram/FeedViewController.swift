//
//  FeedViewController.swift
//  exchangeAGram
//
//  Created by Andrew Morrison on 2016-03-21.
//  Copyright © 2016 Andrew Morrison. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var feedArray:[AnyObject] = []
    
    var locationManager:CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let backgroundImage = UIImage(named: "AutumnBackground")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.requestWhenInUseAuthorization()

        locationManager.startUpdatingLocation()
        
        
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
    
    override func viewDidAppear(animated: Bool) {
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext
        do {
            try feedArray = context.executeFetchRequest(request)
        } catch {
        }
        
        collectionView.reloadData()
    }
    
    
    // IBActions
    
    @IBAction func snapBarButtonItemPressed(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes as! [String]
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes as! [String]
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
            
        } else {
            var alertController = UIAlertController(title: "Uh oh!", message: "Your device does not support the camera or Photo Library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbnailData = UIImageJPEGRepresentation(image, 0.01)
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        feedItem.image = imageData
        feedItem.caption = "Test Caption"
        feedItem.thumbnail = thumbnailData
        
        feedItem.latitude = locationManager.location!.coordinate.latitude
        feedItem.longitude = locationManager.location!.coordinate.longitude
        
        let UUID = NSUUID().UUIDString
        feedItem.uniqueID = UUID
        
        feedItem.filtered = false
        
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        feedArray.append(feedItem)
        
        dismissViewControllerAnimated(true, completion: nil)
        
        collectionView.reloadData()
        
    }
    
    
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:FeedCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCollectionViewCell
        
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        if thisItem.filtered == true {
            let returnedImage = UIImage(data: thisItem.image!)
            let image = UIImage(CGImage: (returnedImage?.CGImage)!, scale: 1.0, orientation: UIImageOrientation.Right)
        } else {
            cell.imageView.image = UIImage(data: thisItem.image!)

        }
        cell.captionLabel.text = thisItem.caption
        
        return cell
        
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
        navigationController?.pushViewController(filterVC, animated: false)
        
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations = \(locations)")
        
    }

}
