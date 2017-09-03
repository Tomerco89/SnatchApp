//
//  WishListTableViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 12/03/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class WishListTableViewController: UITableViewController {

    var dbWishRef: DatabaseReference!
    var dbItemRef: DatabaseReference!
    var user = Auth.auth().currentUser
    var wishItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        dbWishRef = Database.database().reference().child("snatch-users").child((self.user?.uid)!).child("wish-list")
        dbItemRef = Database.database().reference().child("snatch-items")
        startObservingDB()
    }
    
    func startObservingDB() {
        dbWishRef.observeSingleEvent(of: .value, with: { snapshot in
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let value = item.value as? NSDictionary
                let itemRef = value?.value(forKey: "key") as! String
                
                self.dbItemRef.child(itemRef).observeSingleEvent(of: .value, with: { (snapshot) in
                let realItem = snapshot
                let itemObject = Item(snapshot: realItem )
                self.wishItems.append(itemObject)
                self.tableView.reloadData()
                })
            }
        })
    }
    

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishCell", for: indexPath)
        
        cell.textLabel?.text = wishItems[indexPath.row].itemName
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont(name:"Helvetica Neue", size:20)
        cell.textLabel?.text = cell.textLabel?.text?.capitalized
        
        return cell
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return wishItems.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToRemove = dbWishRef.child(wishItems[indexPath.row].key)
            itemToRemove.removeValue()
            wishItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "WishListItem" {
            let vc = segue.destination as! ItemViewController,
            itemIndex = tableView.indexPathForSelectedRow?.row
            vc.item = wishItems[itemIndex!]
        }
    }

}
