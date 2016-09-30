//
//  File.swift
//  BlightnessPlayer
//
//  Created by TakeshiKaneko on 2016/09/30.
//  Copyright © 2016年 knktkc. All rights reserved.
//

import UIKit

@IBDesignable
class Button_Custom: UIButton {
    
    @IBInspectable var textColor: UIColor?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
}
