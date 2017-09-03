//
//  SwipeItemsViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 20/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class SwipeItemsViewController: UIViewController {
    @IBOutlet weak var topCardItemImage: UIImageView!
    @IBOutlet weak var topCardItemPrice: UILabel!
    @IBOutlet weak var topCardItemName: UILabel!
    @IBOutlet weak var topCardSellerName: UILabel!
    @IBOutlet weak var topCardSellerRating: UILabel!
    
    @IBOutlet weak var bottomCardItemImage: UIImageView!
    @IBOutlet weak var bottomCardItemPrice: UILabel!
    @IBOutlet weak var bottomCardItemName: UILabel!
    @IBOutlet weak var bottomCardSellerName: UILabel!
    @IBOutlet weak var bottomCardSellerRating: UILabel!
    
    var startAt = "0", endAt = "10"
    var dbRef: DatabaseReference!
    var dbUserRef: DatabaseReference!
    var dbWishRef: DatabaseReference!
    var tenItemsDbRef: DatabaseQuery?
    
    var divisor: CGFloat!
    
    var snatchItems = [Item]()
    var SnatchSellers = [User]()

    var topShadow: EdgeShadowLayer!

    @IBOutlet weak var topCard: UIView!
    @IBOutlet weak var bottomCard: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        divisor = (view.frame.width/2) / 0.44
        bottomCardItemImage.clipsToBounds = true
        topCardItemImage.clipsToBounds = true

        dbRef = Database.database().reference().child("snatch-items")
        dbWishRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("wish-list")
        
        setAllShadows()
        
        getTenItems()
        
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        card.transform = CGAffineTransform(rotationAngle: xFromCenter/divisor)
        
        if sender.state == UIGestureRecognizerState.ended {
        
            if card.center.x < 75 {
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                    self.addToWishList()
                    if (self.snatchItems.count == 1) {
                        self.outOfItems()
                    }
                    self.snatchItems.remove(at: 0)
                    self.SnatchSellers.remove(at: 0)

                })
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    self.nextCards()
                    self.resetCard()
                })
                if snatchItems.count == 2 {
                    self.getTenItems()
                }
                return
            } else if card.center.x > (view.frame.width - 75) {
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                    if (self.snatchItems.count == 1) {
                        self.outOfItems()
                    }
                    self.snatchItems.remove(at: 0)
                    self.SnatchSellers.remove(at: 0)

                })
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    self.nextCards()
                    self.resetCard()
                })
                
                if snatchItems.count == 2 {
                    self.getTenItems()
                }
                return
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                card.center = self.view.center
                card.transform = .identity
            })
        }
    }

    func resetCard() {
        self.topCard.center = CGPoint(x: self.view.center.x, y: 347)
        self.topCard.alpha = 1
        self.topCard.transform = .identity
    }
    
    func getTenItems() {
        if snatchItems.count == 0 {
            tenItemsDbRef = dbRef.queryOrderedByKey().queryLimited(toFirst: 10)
        }
        else {
            tenItemsDbRef = dbRef.queryOrderedByKey().queryStarting(atValue: snatchItems[1].key).queryLimited(toFirst: 10)
        }
        tenItemsDbRef?.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
            for item in snapshot.children {
                var itemObject = Item(snapshot: item as! DataSnapshot)
                self.dbUserRef = Database.database().reference().child("snatch-users").child((itemObject.addedByUser)!)
                self.dbUserRef.observeSingleEvent(of: .value, with: { snapshot in
                    let seller = User(snapshot: snapshot)
                    self.SnatchSellers.append(seller)
                    let imageView = UIImageView()
                    imageView.setImageFromURL(stringImageUrl: itemObject.itemPhotoUrl)
                    itemObject.itemPhoto = imageView.image
                    self.snatchItems.append(itemObject)
                    if (self.snatchItems.count == 2) {
                        self.setCards()
                    }
                })
            }
        })

        
    }
    


    func setCards() {
        self.topCardItemImage.downloadedFrom(link: snatchItems[0].itemPhotoUrl)
        self.topCardItemName.text = snatchItems[0].itemName
        self.topCardItemPrice.text = snatchItems[0].itemPrice
        self.topCardSellerName.text = SnatchSellers[0].username
        self.topCardSellerRating.text = "5 Stars"
        

        self.bottomCardItemImage.downloadedFrom(link: snatchItems[1].itemPhotoUrl)
        self.bottomCardItemName.text = snatchItems[1].itemName
        self.bottomCardItemPrice.text = snatchItems[1].itemPrice
        self.bottomCardSellerName.text = SnatchSellers[1].username
        self.bottomCardSellerRating.text = "5 Stars"
        
    }
    
    func nextCards() {
        self.topCardItemImage.image = self.bottomCardItemImage.image
        self.topCardItemName.text = self.bottomCardItemName.text
        self.topCardItemPrice.text = self.bottomCardItemPrice.text
        self.topCardSellerName.text = self.bottomCardSellerName.text
        self.topCardSellerRating.text = self.bottomCardSellerRating.text
        
        
        if (self.snatchItems.count >= 2) {
            self.bottomCardItemImage.downloadedFrom(link: snatchItems[1].itemPhotoUrl)
            self.bottomCardItemName.text = snatchItems[1].itemName
            self.bottomCardItemPrice.text = snatchItems[1].itemPrice
            self.bottomCardSellerName.text = SnatchSellers[1].username
            self.bottomCardSellerRating.text = "5 Stars"
        }
        else {
            
        }
    }
    
    func addToWishList() {
        let wishItemRef = self.dbWishRef.child(snatchItems[0].key).child("key")
        wishItemRef.setValue(snatchItems[0].key)
    }
    
    func setTextShadow(textToShadow: UILabel) {
        
        textToShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        textToShadow.layer.shadowOpacity = 1
        textToShadow.layer.shadowRadius = 3
    }
    
    func setAllShadows() {
        
        setTextShadow(textToShadow: topCardItemName)
        setTextShadow(textToShadow: topCardItemPrice)
        setTextShadow(textToShadow: topCardSellerName)
        setTextShadow(textToShadow: topCardSellerRating)
        setTextShadow(textToShadow: bottomCardItemName)
        setTextShadow(textToShadow: bottomCardItemPrice)
        setTextShadow(textToShadow: bottomCardSellerName)
        setTextShadow(textToShadow: bottomCardSellerRating)

    }
    
    func outOfItems() {
        topCardItemName.text = ""
        topCardItemPrice.text = ""
        topCardSellerName.text = ""
        topCardSellerRating.text = ""
        topCardItemImage.image = #imageLiteral(resourceName: "image-placeholder")
        
        bottomCardItemName.text = ""
        bottomCardItemPrice.text = ""
        bottomCardSellerName.text = ""
        bottomCardSellerRating.text = ""
        bottomCardItemImage.image = #imageLiteral(resourceName: "image-placeholder")
        
    }

}

extension UIImageView {
    
    func setImageFromURL(stringImageUrl url: String){
        
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
