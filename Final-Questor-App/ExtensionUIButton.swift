//
//  ExtensionUIButton.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 5/18/17.
//  Copyright © 2017 Adrian Humphrey. All rights reserved.
//

import Foundation

extension UIButton {
    /**
     Get Set Height
     
     - parameter height: CGFloat
     by DaRk-_-D0G
     */
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    /**
     Get Set Width
     
     - parameter width: CGFloat
     by DaRk-_-D0G
     */
    var width:CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    
}
