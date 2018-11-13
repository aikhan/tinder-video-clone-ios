//
//  SliderTableViewCell.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 1/30/17.
//  Copyright © 2017 Adrian Humphrey. All rights reserved.
//

import UIKit


final class SliderTableViewCell: UITableViewCell, Cell {
    
    let rangeSlider1 = RangeSlider(frame: CGRect.zero)

    static func nib() -> UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    func configure(row: Row){
        
        addSubview(rangeSlider1)
        rangeSlider1.addTarget(self, action: #selector(SliderTableViewCell.rangeSliderValueChanged(_:)), for: .valueChanged)
    }
    
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
    }
    
}



