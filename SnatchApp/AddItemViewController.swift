//
//  AddItemViewController.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 15/03/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ImagePicker
import Lightbox
import Photos
import MapKit



class AddItemViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    ImagePickerDelegate,
    CLLocationManagerDelegate,
    SelectCategoryTableViewControllerDelegate
{


    var currentUserDbRef: DatabaseReference!
    var dbCatRef: DatabaseReference!
    let storage = Storage.storage()
    var storageRef: StorageReference!
    var dbRef: DatabaseReference!
    var dbUserRef: DatabaseReference!
    var user = Auth.auth().currentUser
    var currentUser: User!
    var images: [UIImage] = []
    var locationManager: CLLocationManager!
    var location: CLLocation!
    var isPickedImage: Bool! = false
    var categories: [String] = [String]()
    var selectedCategory: String = ""


    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sell Something"
        currentUserDbRef = Database.database().reference().child("snatch-users").child((self.user?.uid)!)
        dbCatRef = Database.database().reference().child("snatch-categories")
        dbUserRef = Database.database().reference().child("snatch-users").child((self.user?.uid)!).child("user-items")
        dbRef = Database.database().reference().child("snatch-items")
        storageRef = storage.reference()
        itemName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        itemPrice.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        
        currentUserDbRef.observe(DataEventType.value, with: { (snapshot: DataSnapshot) in
            
            self.currentUser = User(snapshot: snapshot)
            
        })

        
        populateCategories()

        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    func textFieldDidChange(_ textField: UITextField) {
        if itemName.text == "" || itemPrice.text == "" || !isPickedImage {
            doneBtn.isEnabled = false
        } else {
            if itemDescription.text.isEmpty {
                itemDescription.text = "No Description"
            }
            doneBtn.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last as CLLocation!
    }
    
    
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
                let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
    }
    
    public func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.images = images
        self.isPickedImage = true
        self.textFieldDidChange(itemPrice)
        

        imagePicker.dismiss(animated: true, completion: nil)
    }
    public func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postItem(_ sender: Any) {
        var imageUrl: String!
        let itemRef = self.dbRef.childByAutoId()
        for i in 0..<(images.count) {
            self.images[i] = self.images[i].resizeImage(newWidth: 800)
            let imageRef = storageRef.child("images/\(user!.uid)/\(itemRef.key)/\(i).png")
            _ = imageRef.putData(UIImagePNGRepresentation(images[i])!, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    print("error uploading picture")
                    return
                }
                if (error == nil) {
                    imageUrl = metadata!.downloadURL()?.absoluteString
                }
            }
        }
        let timeStamp = Date().toMillis()
        let snatchItem = Item(itemName: self.itemName.text!, itemDescription: self.itemDescription.text!, itemPrice: self.itemPrice.text!, addedByUser: (self.user?.uid)!, sellerName: self.currentUser.username, itemPhotoUrl: imageUrl, latitude: String(describing: (self.location?.coordinate.latitude)!), longitude: String(describing: (self.location?.coordinate.longitude)!), category: selectedCategory, timeStamp: timeStamp!)
        itemRef.setValue(snatchItem.toAny())
        let userItemRef = dbUserRef.child(itemRef.key).child("key")
        userItemRef.setValue(itemRef.key)
    }




    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func populateCategories() {
        dbRef.observe(.value, with: {
            snapshot in
            for category in snapshot.children {
                self.categories.append((category as AnyObject).key)
            }
        })
    }

    func textChanged(text: String?) {
        selectedCategory = text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SelectCategoryTableViewController {
            controller.delegate = self
        }
    }

}

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    } }

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
