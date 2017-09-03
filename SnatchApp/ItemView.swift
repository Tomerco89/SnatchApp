//
//  ItemView.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 25/06/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFromUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: {[unowned self] response, data, error in
                if let data = data {
                    self.image = UIImage(data: data)
                }
            })
        }
    }
}

class ItemView: UIView {
    
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet var photoImageView: UIImageView?
    @IBOutlet weak var itemDescriptionLabel: UITextView!
    @IBOutlet var itemNameLabel: UILabel?
    @IBOutlet var itemPriceLabel: UILabel?
    @IBOutlet var itemSellerNameLabel: UILabel?
}
