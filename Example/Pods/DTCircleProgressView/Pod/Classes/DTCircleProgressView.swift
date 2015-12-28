//
//  DTCircleView.swift
//  ComponentsPlayground
//
//  Created by Daniel Tjuatja on 22/9/15.
//  Copyright © 2015 Daniel Tjuatja. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class DTCircleProgressView: UIView {
    
    
    @IBInspectable public var valueString : String = "Title" {
        didSet { updateTitleLabel() }
    }
    @IBInspectable public var showUnit : Bool = false
    @IBInspectable public var valueUnit : String = "-" {
        didSet { updateTitleLabel() }
    }
    
    
    @IBInspectable public var fontColor : UIColor = UIColor.whiteColor() {
        didSet  { titleLbl.textColor = fontColor }
    }
    @IBInspectable public var fontSize : CGFloat = 15 {
        didSet { updateTitleLabel() }
    }
    @IBInspectable public var fontName : String = "HelveticaNeue" {
        didSet { updateTitleLabel() }
    }
    
    func updateTitleLabel() {
        
        if showUnit {
            
            let title = NSMutableAttributedString(string: "")
            
            var valueFont = UIFont(name: fontName as String, size: fontSize)
            if valueFont == nil {
                valueFont = UIFont.systemFontOfSize(fontSize)
            }
            
            
            var attr = [NSFontAttributeName :valueFont!]
            let valueAttrStr = NSAttributedString(string: valueString as String, attributes: attr)
            
            title.appendAttributedString(valueAttrStr)
            title.appendAttributedString(NSAttributedString(string: "\n"))
            
            var unitFont = UIFont(name: fontName as String, size: fontSize * 0.5)
            if unitFont == nil {
                unitFont = UIFont.systemFontOfSize(fontSize * 0.5)
            }
            
            
            attr = [NSFontAttributeName : unitFont!]
            let unitAttrStr = NSAttributedString(string: valueUnit as String, attributes: attr)
            
            title.appendAttributedString(unitAttrStr)
            
            titleLbl.attributedText = title
            
        }
        else {
            titleLbl.font = UIFont(name: fontName as String, size: fontSize)
            titleLbl.text = valueString as String
        }
        
    }
    
    @IBInspectable public var bgColor : UIColor = UIColor.clearColor()
    @IBInspectable public var borderColor : UIColor = UIColor.whiteColor()
    @IBInspectable public var progressColor : UIColor = UIColor.purpleColor()
    
    
    @IBInspectable public var borderWidth : CGFloat = 1.0
    @IBInspectable public var borderAlpha : CGFloat = 1.0
    
    
    
    @IBInspectable public var progressAngle : Double = 100.0
    @IBInspectable public var progressRotationAngle : Double = 0.0
    @IBInspectable public var progressRotationStart : Double = 0.0
    @IBInspectable public var value : Double = 50.0 {
        didSet {
            if value < 0 {
                value = 0
            }
        }
    }
    @IBInspectable public var maxValue : Double = 100.0
    
    @IBOutlet weak var titleLbl: UILabel!
    
    
    var view : UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "DTCircleProgressView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options : nil)[0] as! UIView
        
        return view
    }
    
    
    public override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()

        
        
        // DRAW BORDER LINE
        CGContextSetLineWidth(ctx, borderWidth)
        borderColor = borderColor.colorWithAlphaComponent(borderAlpha)
        CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor)
        CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
        let rect = bounds.insetBy(dx: borderWidth, dy: borderWidth)
        CGContextBeginPath(ctx)
        let newSize = min(rect.size.width, rect.size.height)
        let newRect = CGRectMake(borderWidth, borderWidth, newSize, newSize)
        CGContextAddEllipseInRect(ctx, newRect)
        CGContextDrawPath(ctx, .FillStroke)
        
        
        // DRAW CIRCLE FILL
        let ctxB = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(ctxB, 0)
        CGContextSetFillColorWithColor(ctxB, bgColor.CGColor)
        let rectB = bounds.insetBy(dx: borderWidth * 1.5 , dy: borderWidth * 1.5)
        CGContextBeginPath(ctxB)
        let newSizeB = min(rectB.size.width, rectB.size.height)
        let newRectB = CGRectMake(borderWidth * 1.5, borderWidth * 1.5, newSizeB, newSizeB)
        CGContextAddEllipseInRect(ctx, newRectB)
        CGContextDrawPath(ctxB, .FillStroke)
        
        
        // DRAW PROGRESS BAR
        let startAngle = (progressAngle / 100.0) * M_PI - ((-progressRotationAngle / 100.0) * 2.0 + 0.5) * M_PI - (2.0 * M_PI) * (progressAngle / 100.0) * (100.0 - 100.0 * value / maxValue) / 100.0
        let endAngle = -(progressAngle / 100.0) * M_PI - ((progressRotationAngle / 100.0) * 2.0 + 0.5) * M_PI
        
        let arc = CGPathCreateMutable()
        CGPathAddArc(arc, nil, frame.width/2, frame.height/2, (min(frame.width, frame.height)/2) - borderWidth, CGFloat(startAngle + (M_PI * progressRotationStart / 100.0)), CGFloat(endAngle + (M_PI * progressRotationStart / 100.0)), true)
        
        let strokedArc = CGPathCreateCopyByStrokingPath(arc, nil, borderWidth, CGLineCap.Round, CGLineJoin.Miter, 10)
        
        CGContextAddPath(ctx, strokedArc)
        CGContextSetFillColorWithColor(ctx, progressColor.CGColor)
        CGContextSetStrokeColorWithColor(ctx, UIColor.clearColor().CGColor)
        CGContextDrawPath(ctx, .FillStroke);
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
}

