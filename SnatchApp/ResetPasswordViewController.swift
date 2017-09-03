//
//  ResetPasswordViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 19/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetBtnDidPressed(_ sender: Any) {
        
        Auth.auth().sendPasswordReset(withEmail: emailField.text!) { (error) in
            if error == nil {
            SweetAlert().showAlert("Great!", subTitle: "Verification Email Sent", style: AlertStyle.success)
            }
            else {
                SweetAlert().showAlert("Uh-Oh!", subTitle: error?.localizedDescription, style: AlertStyle.error)
            }
        }
    }
}
