//
//  RadiusRegionViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 08/05/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase

class RadiusRegionViewController: UIViewController {
    
    var user = Auth.auth().currentUser
    var dbRef: DatabaseReference!
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var radius: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dbRef = Database.database().reference().child("snatch-users").child((self.user?.uid)!).child("user-radius")
        self.dbRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let userRadius = value?.value(forKey: "Radius") as? Float ?? 0.0
            self.distance.text = String(Int(userRadius)) + " km"
            self.radius.value = userRadius
            })
        self.radius.minimumValue = 1
        self.radius.maximumValue = 50
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dbRef.child("Radius").setValue(radius.value)
    }

    @IBAction func valueDidChanged(_ sender: Any) {
        self.distance.text = String(Int(radius.value)) + " km"
    }

}
