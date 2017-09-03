//
//  AccountViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 08/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var seller = Auth.auth().currentUser
    var dbRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = Database.database().reference().child("snatch-users").child((seller?.uid)!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
