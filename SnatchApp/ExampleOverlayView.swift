//
//  ExampleOverlayView.swift
//  KolodaView
//
//  Created by Eugene Andreyev on 6/21/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "yesOverlayImage"
private let overlayLeftImageName = "noOverlayImage"

class ExampleOverlayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()

//    override var overlayState: SwipeResultDirection? {
//        didSet {
//            switch overlayState {
//            case .left? :
//                overlayImageView.image = UIImage(named: "like")
//            case .right? :
//                overlayImageView.image = UIImage(named: "trash")
//            default:
//                overlayImageView.image = nil
//            }
//        }
//    }

}
