//
//  ARButton.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/12/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//
//  This is a simple implementation for an AR Button.
//
//  Currently only supports a sprite/image based button background
//  as far as customization goes.

import UIKit
import SceneKit
import ARKit

class ARButton: SCNNode {

    /// The closure that is executed when the button is pressed
    var buttonAction : (() -> Void)?
    
    init(named name: String, withImageNamed filename: String) {
        super.init()
        self.name = name
        
        let backgroundPlane = SCNPlane(width: 0.15, height: 0.15)
        backgroundPlane.firstMaterial?.diffuse.contents = UIImage(named: filename)
        self.geometry = backgroundPlane
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Run the button's buttonAction closure if it has been assigned
    func pressed() {
        buttonAction?()
    }
    
}
