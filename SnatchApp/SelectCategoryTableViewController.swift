//
//  SelectCategoryTableViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 07/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


protocol SelectCategoryTableViewControllerDelegate: class {
    
    func textChanged(text:String?)
    
}

class SelectCategoryTableViewController: UITableViewController {

    weak var delegate: SelectCategoryTableViewControllerDelegate?
    var dbRef: DatabaseReference!
    var categories = [String]()
    var selectedCategory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = false
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
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.tintColor = UIColor.white
        
        cell.textLabel?.text = self.categories[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont(name:"Helvetica Neue", size:20)
        cell.textLabel?.text = cell.textLabel?.text?.capitalized

        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        selectedCategory = currentCell.textLabel!.text!
        delegate?.textChanged(text: selectedCategory)
        }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        selectedCategory = ""
        delegate?.textChanged(text: selectedCategory)
        
    }
    


}


