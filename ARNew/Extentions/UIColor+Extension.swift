//
//  UIColor+Extension.swift
//  FireApp
//
//  Created by Pavel Bogart on 23/02/2018.
//  Copyright © 2018 Pavel Bogart. All rights reserved.
//

import UIKit

public extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

public extension UIColor {
    
    static var greenBorderColor: UIColor = {
        return UIColor(r: 80, g: 227, b: 194)
    }()
    
    static var redBorderColor: UIColor = {
        return UIColor(r: 255, g: 151, b: 164)
    }()
    
}
