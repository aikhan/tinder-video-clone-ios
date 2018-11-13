//
//  GradientHeaderView.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 7/22/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import Foundation

/// Custom header view that displays a gradient layer inside it
@IBDesignable class GradientHeaderView: UIView {
    
    /// Gradient layer that is added on top of the view
    var gradientLayer: CAGradientLayer!
    
    /// Top color of the gradient layer
    @IBInspectable var leftColor: UIColor = OppositeGradientHeaderView.hexStringToUIColor("#FF340E") {
        didSet {
            updateUI()
        }
    }
    
    /// Bottom color of the gradient layer       // For some reason RGB values are not working.#FF350E  FF340E
    @IBInspectable var rightColor: UIColor = OppositeGradientHeaderView.hexStringToUIColor("#FF8B24"){//UIColor(red: 255.0, green: 136, blue: 35, alpha:1.0){
        didSet {
            updateUI()
        }
    }
    
    /// At which vertical point the layer should end
    @IBInspectable var bottomYPoint: CGFloat = 0.6 {
        didSet {
            updateUI()
        }
    }
    
        /**
         Updates the UI
         */
        func updateUI() {
        setNeedsDisplay()
        }
        
        /*
        Sets up the gradient layer
    */
    func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.addSublayer(gradientLayer)
    }
        

        /**
         Lays out all the subviews it has, in our case the gradient layer
         */
        override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
        }

        /**
         Initialises the view
         
         - parameter aDecoder: aDecoder
         
         - returns: self
         */
        required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradientLayer()
        }
        
        /**
         Initialises the view
         
         - parameter frame: frame to use
         
         - returns: self
         */
        override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
        }
    
    class func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        //var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
