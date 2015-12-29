//
//  UIColor+Crossfade.swift
//  ComponentsPlayground
//
//  Created by Daniel Tjuatja on 23/11/15.
//  Copyright © 2015 Daniel Tjuatja. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func interpolateRGBColorFrom(startColor : UIColor, toColor : UIColor, var ratio: CGFloat) -> UIColor {
        
        ratio = max(0, ratio)
        ratio = min(1, ratio)
        
        let c1 = CGColorGetComponents(startColor.CGColor)
        let c2 = CGColorGetComponents(toColor.CGColor)
        
        let r = c1[0] + (c2[0] - c1[0]) * ratio
        let g = c1[1] + (c2[1] - c1[1]) * ratio
        let b = c1[2] + (c2[2] - c1[2]) * ratio
        let a = c1[3] + (c2[3] - c1[3]) * ratio
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    
    
}