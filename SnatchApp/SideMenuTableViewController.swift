//
//  SideMenuTableViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 15/01/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Foundation
import SideMenu
import Firebase
import FirebaseAuth


class SideMenuTableViewController: UITableViewController {
    
    
    //@IBOutlet weak var username: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        //let user = FIRAuth.auth()?.currentUser
        //username.text = user?.email
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    @IBAction func unwindFromProfile(segue: UIStoryboardSegue) {
        
    }


    
}
