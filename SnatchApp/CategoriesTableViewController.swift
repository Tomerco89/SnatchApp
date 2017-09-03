//
//  CategoriesTableViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 07/05/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CategoriesTableViewController: UITableViewController {

    var dbRef: DatabaseReference!
    var dbUserCatRef: DatabaseReference!
    var user = Auth.auth().currentUser
    var categories = [String]()
    var selectedCategories = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
        dbUserCatRef = Database.database().reference().child("snatch-users").child((self.user?.uid)!).child("user-categories")
        dbRef = Database.database().reference().child("snatch-categories")
        populateCategories()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    func populateCategories() {
        dbRef.observe(.value, with: {
            snapshot in
            for category in snapshot.children {
                self.categories.append((category as AnyObject).key)
            }
            self.tableView.reloadData()
        })
        dbUserCatRef.observe(.value, with: {
            snapshot in
            for category in snapshot.children {
                self.selectedCategories.append((category as AnyObject).key)
            }
            self.markedSelectedCells()
        })

        
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.tintColor = UIColor.blue
        
        cell.textLabel?.text = self.categories[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell

        if (!selectedCategories.contains(currentCell.textLabel!.text!)) {
            self.selectedCategories.append(currentCell.textLabel!.text!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        var toDelete = -1
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        for index in 0...selectedCategories.count-1 {
            if selectedCategories[index] == currentCell.textLabel!.text! {
                toDelete = index
            }
        }
        if (toDelete != -1) {
            dbUserCatRef.child(selectedCategories[toDelete]).setValue(nil)
            self.selectedCategories.remove(at: toDelete)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        for category in selectedCategories {
            let newRef = dbUserCatRef.child(category)
            newRef.setValue(category)
        }
        
    }
    
    func markedSelectedCells() {
        
        let cells = self.tableView.visibleCells 
        
        for cell in cells {
            if selectedCategories.contains((cell.textLabel?.text)!) {
                cell.accessoryType = .checkmark
                cell.setSelected(true, animated: false)
            }
        }
        self.tableView.reloadData()
    }

}
