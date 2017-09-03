//
//  MapViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 14/01/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var realItems = [Item]()
    
    //let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        addItemAsAnnotations()
        

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last as CLLocation!
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        }

    func addItemAsAnnotations() {
        if realItems.count != 0 {
            for index in 0...realItems.count-1  {
                let annotation = MKPointAnnotation()  // <-- new    instance here
                annotation.coordinate.latitude = Double(realItems[index ].latitude)!
                annotation.coordinate.longitude = Double(realItems  [index].longitude)!
                annotation.title = realItems[index].itemName
                mapView.addAnnotation(annotation)
            }
        }
    }


}
