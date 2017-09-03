//
//  MyKolodaViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 24/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Koloda
import Firebase
import SideMenu

class MyKolodaViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    var dbRef: DatabaseReference!
    var dbUserRef: DatabaseReference!
    var dbWishRef: DatabaseReference!
    var tenItemsDbRef: DatabaseQuery?
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    fileprivate var dataSource: [Item] = {
        var array: [Item] = []
        return array
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        dbRef = Database.database().reference().child("snatch-items")
        
//        let url = URL(string: "https://httpbin.org/ip")
//        
//        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//            guard error == nil else {
//                print(error!)
//                return
//            }
//            guard let data = data else {
//                print("Data is empty")
//                return
//            }
//            
//            let json = try! JSONSerialization.jsonObject(with: data, options: [])
//            print(json)
//        }
//        
//        task.resume()
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        initSideMenu()
        getTenItems()
    }
    
    
    // MARK: IBActions
    
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    func getTenItems() {
        if dataSource.count == 0 {
            tenItemsDbRef = dbRef.queryOrderedByKey().queryLimited(toFirst: 10)
        }
        else {
            tenItemsDbRef = dbRef.queryOrderedByKey().queryStarting(atValue: dataSource[1].key).queryLimited(toFirst: 10)
        }
        tenItemsDbRef?.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
            for item in snapshot.children {
                let itemObject = Item(snapshot: item as! DataSnapshot)
                    self.dataSource.append(itemObject)
            }
            self.kolodaView.reloadData()
        })
        
    }
    
    func kolodaDidSwipedCardAtIndex(koloda: KolodaView, index: UInt, direction: SwipeResultDirection) {
        if dataSource.count - Int(index) < 5 {
            getTenItems()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItem" {
            let vc = segue.destination as! ItemViewController
            vc.item = dataSource[kolodaView.currentCardIndex]
        }
    }


}

// MARK: KolodaViewDelegate

extension MyKolodaViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {

    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        self.performSegue(withIdentifier: "ShowItem", sender: nil)
    }
    
}

// MARK: KolodaViewDataSource

extension MyKolodaViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {

        let photoView = Bundle.main.loadNibNamed("ItemView", owner: self, options: nil)?[0] as? ItemView
        photoView?.photoImageView?.imageFromUrl(dataSource[index].itemPhotoUrl)
        photoView?.itemNameLabel?.text = dataSource[index].itemName
        photoView?.itemPriceLabel?.text = dataSource[index].itemPrice
        photoView?.itemSellerNameLabel?.text = dataSource[index].sellerName
        photoView?.itemDescriptionLabel.text = dataSource[index].itemDescription
        photoView?.photoImageView?.clipsToBounds = true
        photoView?.layer.shadowColor = UIColor.black.cgColor
        photoView?.layer.shadowOffset = CGSize(width: 0.0, height: 4.0);
        photoView?.layer.shadowOpacity = 0.5
        photoView?.layer.shadowRadius = 4.0
        
        return photoView!
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}
