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
    
    
    
    @IBInspectable public var lineColor : UIColor = UIColor.blue()
    @IBInspectable public var dashedWidth : CGFloat = 10
    @IBInspectable public var isHorizontal : Bool = true
    
    //@IBInspectable var dashedSpace : CGFloat = 10
    
    
    var view : UIView!
    
    
    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(frame.size.height)
        context?.setStrokeColor(lineColor.cgColor)
        let dashArray : [CGFloat] = [dashedWidth]
        context?.setLineDash(phase: 1, lengths: dashArray , count: 1)
        
        //CGContextMoveToPoint(context, 0, frame.size.height/2)
        if isHorizontal {
            context?.moveTo(x: 0, y: frame.size.height/2)
            context?.addLineTo(x: frame.size.width, y: frame.size.height/2)
        }
        else {
            context?.moveTo(x: frame.size.width/2, y: 0)
            context?.addLineTo(x: frame.size.width/2, y: frame.size.height)
        }
        context?.strokePath()
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: self.dynamicType)
        let nib = UINib(nibName: "HMTodayActivityView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options : nil)[0] as! UIView
        
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
