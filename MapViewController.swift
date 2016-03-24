//
//  MapViewController.swift
//  exchangeAGram
//
//  Created by Andrew Morrison on 2016-03-23.
//  Copyright © 2016 Andrew Morrison. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        var itemArray:[FeedItem] = []
        do {
            itemArray = try context.executeFetchRequest(request) as! [FeedItem]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        for item in itemArray {
            let latitude:Double = item.latitude as! Double
            let longitude:Double = item.longitude as! Double
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(location, span)
            //Note - will only reset map to show last location.
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = item.caption
            mapView.addAnnotation(annotation)
        }

    
    
    
//        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(location, span)
//        mapView.setRegion(region, animated: true)
//        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        annotation.title = "Canal Saint-Martin"
//        annotation.subtitle = "Paris"
//        mapView.addAnnotation(annotation)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
