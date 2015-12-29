//
//  DTDashedLineView.swift
//  Glyco
//
//  Created by Daniel Tjuatja on 21/9/15.
//  Copyright © 2015 Holmusk. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable

public class DTDashedLineView: UIView{
    
    
    
    @IBInspectable public var lineColor : UIColor = UIColor.blueColor()
    @IBInspectable public var dashedWidth : CGFloat = 10
    @IBInspectable public var isHorizontal : Bool = true
    
    //@IBInspectable var dashedSpace : CGFloat = 10
    
    
    var view : UIView!
    
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, frame.size.height)
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        let dashArray : [CGFloat] = [dashedWidth]
        CGContextSetLineDash(context, 1, dashArray , 1)
        
        //CGContextMoveToPoint(context, 0, frame.size.height/2)
        if isHorizontal {
            CGContextMoveToPoint(context, 0, frame.size.height/2)
            CGContextAddLineToPoint(context, frame.size.width, frame.size.height/2)
        }
        else {
            CGContextMoveToPoint(context, frame.size.width/2, 0)
            CGContextAddLineToPoint(context, frame.size.width/2, frame.size.height)
        }
        CGContextStrokePath(context)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "HMTodayActivityView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options : nil)[0] as! UIView
        
        return view
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //xibSetup()
    }
    
    
    
    
    
}
