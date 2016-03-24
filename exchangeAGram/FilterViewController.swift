//
//  FilterViewController.swift
//  exchangeAGram
//
//  Created by Andrew Morrison on 2016-03-21.
//  Copyright © 2016 Andrew Morrison. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem:FeedItem!
    
    var collectionView:UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    let placeHolderImage = UIImage(named: "runner-silhouette.jpg")
    
    let tmp = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyFilterCell")
        
        view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UICollectionViewDataSource
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyFilterCell", forIndexPath: indexPath) as! FilterCell
        
        cell.imageView.image = placeHolderImage
        
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        dispatch_async(filterQueue, { () -> Void in
            
            let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbnail!, filter: self.filters[indexPath.row])
            
            //let filterImage = self.getCachedImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })

        return cell
    }
    
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        createUIAlertController(indexPath)
        
    }
    
    //MARK: - Helper Functions
    
    func photoFilters() -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls?.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia?.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp!.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp!.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite?.setValue(sepia?.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette?.setValue(composite?.outputImage, forKey: kCIInputImageKey)
        vignette?.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette?.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        //return [blur!]
        return [blur!,instant!,noir!,transfer!,unsharpen!,monochrome!,colorControls!,sepia!,composite!,vignette!]
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage!
        
        let extent = filteredImage.extent
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage
    }
    
    //MARK: - UIAlertController Helper functions
    
    func createUIAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption"
            textField.secureTextEntry = false
        }
        
        var text:String
        
        let textField = alert.textFields![0] as UITextField
        
        if textField.text != nil {
            text = textField.text!
        }
        
        
        // If we're logged into Facebook, present post option
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let photoAction: UIAlertAction = UIAlertAction(title: "Post to Facebook", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
                
                var text = textField.text
                self.shareToFacebook(indexPath, caption: text!)
                self.saveFilterToCoreData(indexPath, caption: text!)
            }
            alert.addAction(photoAction)
        }
        
        let photoAction = UIAlertAction(title: "Post photo to Facebook with caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            
            var text = textField.text

            self.saveFilterToCoreData(indexPath, caption: text!)
        }
        alert.addAction(photoAction)
        
        
        let saveFilterAction = UIAlertAction(title: "Save filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            var text = textField.text

            self.saveFilterToCoreData(indexPath, caption: text!)
        }
        alert.addAction(saveFilterAction)
        
        
        let cancelAction = UIAlertAction(title: "Select another filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in

        }
        alert.addAction(cancelAction)
        
        

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveFilterToCoreData(indexPath: NSIndexPath, caption: String) {
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image!, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.05)
        self.thisFeedItem.thumbnail = thumbnailData
        self.thisFeedItem.caption = caption
        self.thisFeedItem.filtered = true
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func shareToFacebook(indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image!, filter: self.filters[indexPath.row])
    }
    
    //MARK: - FB Sharing, liking and posting
    
    func shareToFacebook(indexPath: NSIndexPath, caption: String) {
        
        // If not logged into Facebook, alert user
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            self.quickAlert("Warning", message: "You do not appear to be logged in to Facebook.")
        }
        else
        {
            // Get the image data for the full size filtered image
            let filterImage = self.filteredImageFromImage(self.thisFeedItem.image!, filter: filters[indexPath.row])
            let imageData: NSData = UIImageJPEGRepresentation(filterImage, 1.0)!
            
            // Build a Facebook Graph request to add a photo with description
            let params = [ "data" : imageData, "name" : caption ]
            var fbGraphRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: params, HTTPMethod: "POST")
            // Create a Facebook Graph connection and add the request object with callback handler
            var fbConnection = FBSDKGraphRequestConnection()
            fbConnection.addRequest(fbGraphRequest, completionHandler: { (connection, result, error) in
                if (error != nil)
                {
                    print( "\(error.localizedDescription)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Error", message: "Problem posting photo.\r\nError description: \(error.localizedDescription)")
                    }
                }
                if (result != nil)
                {
                    print( "\(result)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Success", message: "Photo posted to Facebook." )
                        self.likeFacebookPhoto(result["id"]! as! String)
                        self.addCommentToFacebookPhoto(result["id"]! as! String, comment: "This image was posted using ExchangeAGram.")
                    }
                }
            } )
            // Execute the Graph request
            fbConnection.start()
        }
    }
    
    func addCommentToFacebookPhoto(fbObjectID: String, comment: String) {
        
        // If not logged into Facebook, alert user
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            self.quickAlert("Warning", message: "You do not appear to be logged in to Facebook.")
        }
        else
        {
            // Build a Facebook Graph request to add a comment to a photo
            let params = [ "message" : comment ]
            var fbGraphRequest = FBSDKGraphRequest(graphPath: "\(fbObjectID)/comments", parameters: params, HTTPMethod: "POST")
            // Create a Facebook Graph connection and add the request object with callback handler
            var fbConnection = FBSDKGraphRequestConnection()
            fbConnection.addRequest(fbGraphRequest, completionHandler:  { (connection, result, error) in
                if (error != nil)
                {
                    print( "\(error.localizedDescription)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Error", message: "Problem adding comment to photo.\r\nError description: \(error.localizedDescription)")
                    }
                }
                if (result != nil)
                {
                    print( "Comment added.\r\n\(result)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Success", message: "Comment added to photo.")
                    }
                }
            }  )
            // Execute the Graph request
            fbConnection.start()
        }
    }
    
    func likeFacebookPhoto(fbObjectID: String, unlike: Bool = false) {
        
        // If not logged into Facebook, alert user
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            self.quickAlert("Warning", message: "You do not appear to be logged in to Facebook.")
        }
        else
        {
            // Set the HTTPMethod value based on whether we need to like or unlike
            var method = "POST"
            if (unlike)
            {
                method = "DELETE"
            }
            // Build a Facebook Graph request to like/unlike a photo
            var fbGraphRequest = FBSDKGraphRequest(graphPath: "\(fbObjectID)/likes", parameters: nil, HTTPMethod: method)
            // Create a Facebook Graph connection and add the request object with callback handler
            var fbConnection = FBSDKGraphRequestConnection()
            fbConnection.addRequest(fbGraphRequest, completionHandler:  { (connection, result, error) in
                if (error != nil)
                {
                    print( "\(error.localizedDescription)" )
                    dispatch_async(dispatch_get_main_queue()) {
                        self.quickAlert( "Error", message: "Problem liking photo.\r\nError description: \(error.localizedDescription)")
                    }
                }
                if (result != nil)
                {
                    print( "Like added:\r\n\(result)" )
                }
            }  )
            // Execute the Graph request
            fbConnection.start()
        }
    }

    
    func quickAlert(header: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(closeAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Caching functions - not working
    
//    func cacheImage(imageNumber: Int) {
//        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
//        let uniquePath = NSURL(fileURLWithPath: tmp, isDirectory: true).URLByAppendingPathComponent(fileName)
//        let absolutePath = uniquePath.absoluteString
//        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
//            let data = self.thisFeedItem.thumbnail
//            let filter = self.filters[imageNumber]
//            let image = filteredImageFromImage(data!, filter: filter)
//            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(absolutePath, atomically: true)
//        }
//    }
//    
//    
//    func getCachedImage (imageNumber: Int) -> UIImage {
//        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
//        let uniquePath = NSURL(fileURLWithPath: tmp, isDirectory: true).URLByAppendingPathComponent(fileName)
//        let absolutePath = uniquePath.relativeString
//        var image:UIImage!
//        
//        if NSFileManager.defaultManager().fileExistsAtPath(absolutePath!) {
//            var returnedImage = UIImage(contentsOfFile: absolutePath!)!
//            image = UIImage(CGImage: returnedImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
//        } else {
//            self.cacheImage(imageNumber)
//            var returnedImage = UIImage(contentsOfFile: absolutePath!)!
//            image = UIImage(CGImage: returnedImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
//
//            
//        }
//        return image
//    }
    
    
    
}