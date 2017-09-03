//
//  SellingTableViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 08/05/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class SellingTableViewController: UITableViewController {

    var dbSellingRef: DatabaseReference!
    var dbItemRef: DatabaseReference!
    var user = Auth.auth().currentUser
    var userItems = [Item]()
    var swipeIndex : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dbSellingRef = Database.database().reference().child("snatch-users").child((self.user?.uid)!).child("user-items")
        dbItemRef = Database.database().reference().child("snatch-items")
        startObservingDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        cell.textLabel?.text = userItems[indexPath.row].itemName
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
        return self.userItems.count
    }

    func startObservingDB() {
        dbSellingRef.observeSingleEvent(of: .value, with: { snapshot in
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let value = item.value as? NSDictionary
                let itemRef = value?.value(forKey: "key") as! String
                
                self.dbItemRef.child(itemRef).observeSingleEvent(of: .value, with: { (snapshot) in
                    let realItem = snapshot
                    let itemObject = Item(snapshot: realItem )
                    self.userItems.append(itemObject)
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            self.swipeIndex = indexPath.row
            let itemToRemove = self.dbItemRef.child(self.userItems[indexPath.row].key)
            let userItemToRemove = self.dbSellingRef.child(self.userItems[indexPath.row].key)
            userItemToRemove.removeValue()
            itemToRemove.removeValue()
            self.userItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.backgroundColor = .red
    
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SellingItem" {
            let vc = segue.destination as! SellingItemViewController,
            itemIndex = tableView.indexPathForSelectedRow?.row
            vc.userItem = userItems[itemIndex!]
        }
    }
    
    
    
    @IBAction func unwindFromEditItem(segue: UIStoryboardSegue) {
        
    }



}
