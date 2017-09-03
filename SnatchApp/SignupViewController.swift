//
//  SignupViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 03/01/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupViewController: UIViewController {

    
    var dbUserRef: DatabaseReference!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    var _username: String!
    var _email: String!
    var _password: String!
    var _phoneNumber: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    
    
    @IBAction func completeSignUp(_ sender: Any) {
        
        _username = username.text
        _email = email.text
        _phoneNumber = phoneNumber.text
        
        
        if password.text == repeatPassword.text && isValidEmail(testStr: _email!) {
            _password = password.text
            
            
            if _email == "" {
                let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
            
            Auth.auth().createUser(withEmail: _email!, password: _password!) { (user, error) in
                
                if error == nil {
                    self.dbUserRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("timeStamp")
                    self.dbUserRef.setValue(Date().toMilliseconds())
                    self.dbUserRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("phone")
                    self.dbUserRef.setValue(self._phoneNumber)
                    self.dbUserRef = Database.database().reference().child("snatch-users").child((user?.uid)!).child("username")
                    self.dbUserRef.setValue(self._username)
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username HAWA
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    //self.performSegue(withIdentifier: "signupCompleted", sender: nil)
                    
                } else {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .invalidEmail:
                            print("invalid email")
                        case .emailAlreadyInUse:
                            print("in use")
                        case .weakPassword:
                            print ("weak password")
                        default:
                            print("Create User Error: \(String(describing: error))")
                        }    
                    }                }
                
            }
                
        }
            

    }

        

}
    

}
extension Date {
    func toMilliseconds() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
