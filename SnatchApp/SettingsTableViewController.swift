//
//  SettingsTableViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 18/03/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase


class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signOut(_ sender: Any) {
        let user = Auth.auth().currentUser
        if user != nil {
            try? Auth.auth().signOut()
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)

        }
    }

}


