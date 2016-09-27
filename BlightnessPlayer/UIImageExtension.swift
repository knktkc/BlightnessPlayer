//
//  UIImageExtension.swift
//  BlightnessPlayer
//
//  Created by 合田竜志 on 2016/09/27.
//  Copyright © 2016年 knktkc. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func getPixelColor(pos: CGPoint) -> (CGFloat, CGFloat, CGFloat, CGFloat){
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage!)!)
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return (red: r, green: g, blue: b, alpha: a)
    }
}
