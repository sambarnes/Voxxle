//
//  UIColor.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/10/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func random() -> UIColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
