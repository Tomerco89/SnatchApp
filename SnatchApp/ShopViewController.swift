    //
//  ShopViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 07/01/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Koloda
import pop
import SideMenu
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation


private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 1
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class ShopViewController: UIViewController, CLLocationManagerDelegate {
    
    var ref: DatabaseReference!
    var dbRef: DatabaseReference!
    var dbUserCatRef: DatabaseReference!
    var dbWishRef: DatabaseReference!
    var dbRadiusRef: DatabaseReference!
    var tempItems = [Item]()
    var realItems = [Item]()
    var categories = [String]()
    var locationManager: CLLocationManager!
    var location: CLLocation!
    var userRadius: Float = 0.0
    
    
    @IBOutlet weak var kolodaView: CustomKolodaView!
    
    func startObservingDB() {
        dbRef.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
            var newItems = [Item]()
            for item in snapshot.children {
                let itemObject = Item(snapshot: item as! DataSnapshot)
                
                if (self.calcDistance(itemLat: itemObject.latitude, itemLng: itemObject.longitude) || self.userRadius == 0.0) {
                    if (self.categories.count != 0) {
                        if (self.categories.contains(itemObject.category)) {
                            newItems.append(itemObject)
                        }
                    }
                    else{
                        newItems.append(itemObject)
                    }
                }
            }
            
            self.tempItems = newItems
            self.buildItems()
        })
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        dbWishRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("wish-list")
        dbRadiusRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("user-radius")
        dbRef = Database.database().reference().child("snatch-items")
        dbUserCatRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("user-categories")
        
        self.dbRadiusRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let radius = value?.value(forKey: "Radius") as? Float ?? 0.0
            self.userRadius = radius
        })

        let url = URL(string: "https://httpbin.org/ip")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        }
        
        task.resume()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }

        
        startObservingDB()
        initKoloda()
        initSideMenu()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last as CLLocation!
    }
    
    func populateCategories() {
        dbUserCatRef.observe(.value, with: {
            snapshot in
            for category in snapshot.children {
                self.categories.append((category as AnyObject).key)
            }
        })

    }
    
    override func viewDidAppear(_ animated: Bool) {
        kolodaView.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if direction == SwipeResultDirection.right {
            // implement your functions or whatever here
            let wishItemRef = self.dbWishRef.child(realItems[kolodaView.currentCardIndex-1].key).child("key")
            wishItemRef.setValue(realItems[kolodaView.currentCardIndex-1].key)

        } else if direction == .left {
            // implement your functions or whatever here
            
        }
    }
    
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
        //self.realItems.remove(at: kolodaView.currentCardIndex)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    func initKoloda() {
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
    
    func initSideMenu() {
        SideMenuManager.menuLeftNavigationController = storyboard?.instantiateViewController(withIdentifier :"LeftMenuNavigationController") as?UISideMenuNavigationController
        SideMenuManager.menuRightNavigationController = storyboard?.instantiateViewController(withIdentifier :"RightMenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        //SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
    }
    
    @IBAction func refreshKoloda() {
        self.kolodaView.reloadData()
    }
    @IBAction func unwindFromAddItem(segue: UIStoryboardSegue) {
        
    }
    
    func buildItems() {
        var flag: Bool
        for item in tempItems {
            flag = true
            let imageReference = Storage.storage().reference(forURL: item.itemPhotoUrl)
            
            imageReference.getData(maxSize: 100 * 1024 * 1024) { data, error in
                if error != nil {
                    // Uh-oh, an error occurred!
                    //print("Failed")
                } else {
                    
                    for realItem in self.realItems {
                        if realItem.itemPhotoUrl == item.itemPhotoUrl {
                            flag = false
                        }
                        else {
                            flag = true
                        }
                    }
                    if flag {
                    let image = UIImage(data: data!)
                        let newItem = Item(itemName: item.itemName, itemDescription: item.itemDescription, itemPrice: item.itemPrice, addedByUser: item.addedByUser, sellerName: "tomer", key: item.key, itemPhoto: image!, itemPhotoUrl: item.itemPhotoUrl, latitude: item.latitude, longitude: item.longitude, category: item.category, timeStamp: item.timeStamp)
                    self.realItems.append(newItem)
                    //self.kolodaView.reloadData()
                    }
                    if self.realItems.count == 5 {
                        self.kolodaView.reloadData()
                    }
                }
                
            }
        }

    }
    
    func calcDistance(itemLat: String, itemLng: String) -> Bool {
        
        let itemCoordinate = CLLocation(latitude: Double(itemLat)!, longitude: Double(itemLng)!)
        let userCoordinate = CLLocation(latitude: (self.location?.coordinate.latitude)!, longitude: (self.location?.coordinate.longitude)!)
        
        let distanceInKiloMeters = itemCoordinate.distance(from: userCoordinate)/1000
        
        if (Float(distanceInKiloMeters) <= userRadius) {
            return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemsToMap" ,
            let nextScene = segue.destination as? MapViewController {
            nextScene.realItems = self.realItems
        }
            
    }
    
}

//MARK: KolodaViewDelegate
extension ShopViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
        kolodaView.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //let url = URL(string: "https://yalantis.com/")
        //UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}


extension ShopViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return realItems.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        
//        let outerView = UIView(frame: kolodaView.frameForCard(at: index))
//        outerView.clipsToBounds = false
//        outerView.layer.shadowColor = UIColor.black.cgColor
//        outerView.layer.shadowOpacity = 1
//        outerView.layer.shadowOffset = CGSize.zero
//        outerView.layer.shadowRadius = 10
//        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
//        let photoView = UIImageView(frame: outerView.bounds)
//        photoView.image = realItems[index].itemPhoto
//        photoView.layer.cornerRadius = 10
//        photoView.clipsToBounds = true
//        //photoView.contentMode = UIViewContentMode.scaleAspectFill
//        //outerView.contentMode = UIViewContentMode.scaleAspectFill
//        outerView.addSubview(photoView)
        let photoView = UIImageView(image: realItems[index].itemPhoto)
        photoView.contentMode = UIViewContentMode.scaleAspectFill
        photoView.clipsToBounds = true
        return photoView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }

    
  
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    
    
}

