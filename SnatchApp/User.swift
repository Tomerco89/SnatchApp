//
//  User.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 17/03/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let key: String!
    let username: String!
    let phone: String!
    let email: String!
    let rating: String!
    let ratingCount: Int!
    let userRef: DatabaseReference?
    
    init(username: String, phone: String, email: String, rating: String, key: String = "", ratingCount: Int) {
        
        self.key = key
        self.username = username
        self.phone = phone
        self.email = email
        self.rating = rating
        self.ratingCount = ratingCount
        self.userRef = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        userRef = snapshot.ref
        
        username = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""
        phone = (snapshot.value as? NSDictionary)?["phone"] as? String ?? ""
        email = (snapshot.value as? NSDictionary)?["email"] as? String ?? ""
        rating = (snapshot.value as? NSDictionary)?["rating"] as? String ?? ""
        ratingCount = (snapshot.value as? NSDictionary)?["ratingCount"] as? Int ?? 0
        
    }
    
    func toAny() -> Any {
        return ["key": key, "username": username, "phone": phone, "email": email, "rating": rating, "ratingCount": ratingCount]
    }

}
