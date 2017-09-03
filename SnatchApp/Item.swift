//
//  Item.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 15/03/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage

struct Item {
    
    let key: String!
    let timeStamp: Int64!
    let category: String!
    let itemName: String!
    let itemDescription: String!
    let itemPrice: String!
    let itemPhotoUrl: String!
    let addedByUser: String!
    let sellerName: String!
    let latitude: String!
    let longitude: String!
    let isSold: Bool!
    var itemPhoto: UIImage?
    let itemRef: DatabaseReference?
    
    init(itemName: String, itemDescription: String, itemPrice: String, addedByUser: String, sellerName: String, key: String = "", itemPhoto: UIImage, itemPhotoUrl: String, latitude: String, longitude: String, category: String, timeStamp: Int64) {
        self.key = key
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.itemPrice = itemPrice
        self.addedByUser = addedByUser
        self.sellerName = sellerName
        self.itemRef = nil
        self.itemPhotoUrl = itemPhotoUrl
        self.itemPhoto = itemPhoto
        self.latitude = latitude
        self.longitude = longitude
        self.isSold = false
        self.category = category
        self.timeStamp = timeStamp
    }
    
    init(itemName: String, itemDescription: String, itemPrice: String, addedByUser: String, sellerName: String, key: String = "", itemPhotoUrl: String, latitude: String, longitude: String, category: String, timeStamp: Int64) {
        self.key = key
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.itemPrice = itemPrice
        self.addedByUser = addedByUser
        self.itemRef = nil
        self.itemPhotoUrl = itemPhotoUrl
        self.latitude = latitude
        self.longitude = longitude
        self.isSold = false
        self.category = category
        self.sellerName = sellerName
        self.timeStamp = timeStamp
        
    }

    
    
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        itemDescription = (snapshot.value as? NSDictionary)?["description"] as? String ?? ""
        addedByUser = (snapshot.value as? NSDictionary)?["addedByUser"] as? String ?? ""
        sellerName = (snapshot.value as? NSDictionary)?["sellerName"] as? String ?? ""
        itemPrice = (snapshot.value as? NSDictionary)?["itemPrice"] as? String ?? ""
        itemName = (snapshot.value as? NSDictionary)?["itemName"] as? String ?? ""
        itemPhotoUrl = (snapshot.value as? NSDictionary)?["itemPhotoUrl"] as? String ?? ""
        latitude = (snapshot.value as? NSDictionary)?["latitude"] as? String ?? ""
        longitude = (snapshot.value as? NSDictionary)?["longitude"] as? String ?? ""
        isSold = (snapshot.value as? NSDictionary)?["isSold"] as? Bool ?? false
        category = (snapshot.value as? NSDictionary)?["category"] as? String ?? ""
        timeStamp = (snapshot.value as? NSDictionary)?["timeStamp"] as? Int64 ?? 0
        
        
    }
    
    func toAny() -> Any {
        return ["key": key, "description": itemDescription, "itemPrice": itemPrice, "itemName": itemName, "addedByUser": addedByUser, sellerName: "sellerName", "itemPhotoUrl": itemPhotoUrl, "latitude": latitude, "longitude": longitude, "isSold": isSold, "category": category, "timeStamp": timeStamp]
    }
    
}
