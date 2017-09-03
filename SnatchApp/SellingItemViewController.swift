//
//  SellingItemViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 08/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class SellingItemViewController: UIViewController, SelectCategoryTableViewControllerDelegate {
    
    var dbItemRef: DatabaseReference!
    var userItem: Item!
    var selectedCategory: String = ""

    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemCategory: UILabel!
    @IBOutlet weak var markAsSoldBtn: UIButton!
    @IBOutlet weak var activateListingBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Item"
        dbItemRef = Database.database().reference().child("snatch-items").child(userItem.key)
        itemName.text = userItem.itemName
        itemPrice.text = userItem.itemPrice
        itemDescription.text = userItem.itemDescription
        itemCategory.text = userItem.category
        if userItem.isSold {
            markAsSoldBtn.isEnabled = false
            markAsSoldBtn.isHidden = true
            activateListingBtn.isEnabled = true
            activateListingBtn.isHidden = false
        }
        else {
            markAsSoldBtn.isEnabled = true
            markAsSoldBtn.isHidden = false
            activateListingBtn.isEnabled = false
            activateListingBtn.isHidden = true
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textChanged(text: String?) {
        selectedCategory = text!
        itemCategory.text = selectedCategory
    }

    @IBAction func didFinishEditing(_ sender: Any) {
        dbItemRef.updateChildValues(["itemName": itemName.text!, "itemPrice": itemPrice.text!, "description": itemDescription.text, "category": itemCategory.text!])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SelectCategoryTableViewController {
            controller.delegate = self
        }
    }

    @IBAction func markAsSold(_ sender: Any) {
        dbItemRef.child("isSold").setValue(true)
    }
    @IBAction func activateListing(_ sender: Any) {
        dbItemRef.child("isSold").setValue(false)
    }
}
