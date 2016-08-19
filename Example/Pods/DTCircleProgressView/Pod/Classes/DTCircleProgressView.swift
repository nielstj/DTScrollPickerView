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
open class DTCircleProgressView: UIView {
    
    
    @IBInspectable open var valueString : String = "" {
        didSet { updateTitleLabel() }
    }
    @IBInspectable open var showUnit : Bool = false
    @IBInspectable open var valueUnit : String = "" {
        didSet { updateTitleLabel() }
    }
    
    
    @IBInspectable open var fontColor : UIColor = UIColor.white {
        didSet  { titleLbl.textColor = fontColor }
    }
    @IBInspectable open var fontSize : CGFloat = 15 {
        didSet { updateTitleLabel() }
    }
    @IBInspectable open var fontName : String = "HelveticaNeue" {
        didSet { updateTitleLabel() }
    }
    
    func updateTitleLabel() {
        
        if showUnit {
            
            let title = NSMutableAttributedString(string: "")
            
            var valueFont = UIFont(name: fontName as String, size: fontSize)
            if valueFont == nil {
                valueFont = UIFont.systemFont(ofSize: fontSize)
            }
            
            
            var attr = [NSFontAttributeName :valueFont!]
            let valueAttrStr = NSAttributedString(string: valueString as String, attributes: attr)
            
            title.append(valueAttrStr)
            title.append(NSAttributedString(string: "\n"))
            
            var unitFont = UIFont(name: fontName as String, size: fontSize * 0.5)
            if unitFont == nil {
                unitFont = UIFont.systemFont(ofSize: fontSize * 0.5)
            }
            
            
            attr = [NSFontAttributeName : unitFont!]
            let unitAttrStr = NSAttributedString(string: valueUnit as String, attributes: attr)
            
            title.append(unitAttrStr)
            
            titleLbl.attributedText = title
        }
        else {
            titleLbl.font = UIFont(name: fontName as String, size: fontSize)
            titleLbl.text = valueString as String
        }
        titleLbl.textAlignment = .center
        
    }
    
    @IBInspectable open var bgColor : UIColor = UIColor.clear
    @IBInspectable open var borderColor : UIColor = UIColor.white
    @IBInspectable open var progressColor : UIColor = UIColor.purple
    
    
    @IBInspectable open var borderWidth : CGFloat = 1.0
    @IBInspectable open var borderAlpha : CGFloat = 1.0
    
    
    
    @IBInspectable open var progressAngle : Double = 100.0
    @IBInspectable open var progressRotationAngle : Double = 0.0
    @IBInspectable open var progressRotationStart : Double = 0.0
    @IBInspectable open var value : Double = 50.0 {
        didSet {
            if value < 0 {
                value = 0
            }
        }
    }
    @IBInspectable open var maxValue : Double = 100.0
    
    @IBOutlet weak var titleLbl: UILabel!
    
    
    var view : UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DTCircleProgressView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options : nil)[0] as! UIView
        
        return view
    }
    
    
    open override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        
        
        // DRAW CIRCLE FILL
        let ctxB = UIGraphicsGetCurrentContext()
        ctxB?.setLineWidth(0)
        ctxB?.setFillColor(bgColor.cgColor)
        let rectB = bounds.insetBy(dx: borderWidth * 1.5 , dy: borderWidth * 1.5)
        ctxB?.beginPath()
        let newSizeB = min(rectB.size.width, rectB.size.height)
        let newRectB = CGRect(x: center.x - (newSizeB/2), y: center.y - (newSizeB/2), width: newSizeB, height: newSizeB)
        ctx?.addEllipse(in: newRectB)
        ctxB?.drawPath(using: .fillStroke)
        
        
        // DRAW BORDER BAR
        borderColor = borderColor.withAlphaComponent(borderAlpha)
        let startAngleA = (progressAngle / 100.0) * M_PI - ((-progressRotationAngle / 100.0) * 2.0 + 0.5) * M_PI - (2.0 * M_PI) * (progressAngle / 100.0) * (100.0 - 100.0 * maxValue / maxValue) / 100.0
        let endAngleARight = ((progressRotationAngle / 100.0) * 2.0 + 0.5) * M_PI
        let endAngleA = -(progressAngle / 100.0) * M_PI - endAngleARight
        
        let arcA = CGMutablePath()
        
        arcA.addArc(center: CGPoint(x:frame.width/2, y:frame.height/2),
                    radius: (min(frame.width, frame.height)/2) - borderWidth,
                    startAngle: CGFloat(startAngleA + (M_PI * progressRotationStart / 100.0)),
                    endAngle: CGFloat(endAngleA + (M_PI * progressRotationStart / 100.0)),
                    clockwise: true)
        
        
        //arcA.addArc(nil, x: frame.width/2, y: frame.height/2, radius: (min(frame.width, frame.height)/2) - borderWidth, startAngle: CGFloat(startAngleA + (M_PI * progressRotationStart / 100.0)), endAngle: CGFloat(endAngleA + (M_PI * progressRotationStart / 100.0)), clockwise: true)
        
        let strokedArcA = CGPath(__byStroking: arcA, transform: nil, lineWidth: borderWidth, lineCap: CGLineCap.round, lineJoin: CGLineJoin.miter, miterLimit: 10)
        
        ctx?.addPath(strokedArcA!)
        ctx?.setFillColor(borderColor.cgColor)
        ctx?.setStrokeColor(UIColor.clear.cgColor)
        ctx?.drawPath(using: .fillStroke);
        
        
        // DRAW PROGRESS BAR
        let startAngle = (progressAngle / 100.0) * M_PI - ((-progressRotationAngle / 100.0) * 2.0 + 0.5) * M_PI - (2.0 * M_PI) * (progressAngle / 100.0) * (100.0 - 100.0 * value / maxValue) / 100.0
        let endAngleRight = ((progressRotationAngle / 100.0) * 2.0 + 0.5) * M_PI
        let endAngle = -(progressAngle / 100.0) * M_PI - endAngleRight
        
        let arc = CGMutablePath()
        
        arc.addArc(center: CGPoint(x: frame.width/2, y:frame.height/2),
                   radius: (min(frame.width, frame.height)/2) - borderWidth,
                   startAngle: CGFloat(startAngle + (M_PI * progressRotationStart / 100.0)),
                   endAngle: CGFloat(endAngle + (M_PI * progressRotationStart / 100.0)),
                   clockwise: true)
        
        //arc.addArc(nil, x: frame.width/2, y: frame.height/2, radius: (min(frame.width, frame.height)/2) - borderWidth, startAngle: CGFloat(startAngle + (M_PI * progressRotationStart / 100.0)), endAngle: CGFloat(endAngle + (M_PI * progressRotationStart / 100.0)), clockwise: true)
        
        let strokedArc = CGPath(__byStroking: arc, transform: nil, lineWidth: borderWidth, lineCap: CGLineCap.round, lineJoin: CGLineJoin.miter, miterLimit: 10)
        
        ctx?.addPath(strokedArc!)
        ctx?.setFillColor(progressColor.cgColor)
        ctx?.setStrokeColor(UIColor.clear.cgColor)
        ctx?.drawPath(using: .fillStroke);
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    open func reset() {
        valueString = ""
        valueUnit = ""
        value = 0
        maxValue = 1
        self.setNeedsDisplay()
    }
    
    
    
}

