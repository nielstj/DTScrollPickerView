//
//  DTScrollPicker.swift
//  ComponentsPlayground
//
//  Created by Daniel Tjuatja on 20/11/15.
//  Copyright © 2015 Daniel Tjuatja. All rights reserved.
//

import Foundation
import UIKit
import DTCircleProgressView



public struct DTScrollPickerMarker {
    var value : Double = 0.0
    var topMarker = ""
    var bottomMarker = ""
}

public protocol DTScrollPickerViewDelegate : class {
    func ScrollPickerViewValueDidChange(scrollPicker : DTScrollPickerView, value : Double, unit : String?)
}


public class DTScrollMarkerView: UIView {
    
    @IBOutlet weak var topMarkerLbl : UILabel!
    @IBOutlet weak var bottomMarkerLbl : UILabel!
    @IBOutlet weak var progressView : DTCircleProgressView!
    @IBOutlet weak var dashedLine : DTDashedLineView!
    
}



@IBDesignable
public class DTScrollPickerView: UIView, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet public var button : DTCircleProgressView!
    
    
    @IBOutlet weak var verticalConstraint : NSLayoutConstraint!
    @IBOutlet weak var widthConstraint : NSLayoutConstraint!
    
    
    
    var isPanning = false
    
    var startPoint : CGPoint = CGPointMake(0, 0)
    var buttonStartPoint : CGPoint = CGPointMake(0, 0)
    var deltaValue : Double = 0.0
    var currentRatio : CGFloat = 0.0
    public var delegate : DTScrollPickerViewDelegate?
    
    
    
    
    @IBInspectable public var cellCount : Int = 30 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var minValue : Double = 0.0 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var maxValue : Double = 0.0 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    @IBInspectable public var buttonZoomRatio : CGFloat = 50.0 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    
    @IBInspectable public var CELL_HEIGHT : CGFloat  = 100 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var maxColor : UIColor = UIColor.clearColor() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var minColor : UIColor = UIColor.clearColor() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var unitString : String? {
        didSet {
            if unitString != nil {
                button.showUnit = true
                button.valueString = unitString!
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
    
    @IBInspectable public var buttonFontColor : UIColor = UIColor.whiteColor() {
        didSet  { button.fontColor = buttonFontColor }
    }
    @IBInspectable public var buttonFontName : String = "HelveticaNeue" {
        didSet { button.fontName = buttonFontName }
    }
    @IBInspectable public var buttonBorderColor : UIColor = UIColor.blueColor() {
        didSet { button.borderColor = buttonBorderColor }
    }
    @IBInspectable public var buttonProgressColor : UIColor = UIColor.purpleColor() {
        didSet { button.progressColor = buttonProgressColor }
    }
    @IBInspectable public var buttonBorderAlpha : CGFloat = 1.0 {
        didSet { button.borderAlpha = buttonBorderAlpha }
    }
    @IBInspectable public var buttonBGColor : UIColor = UIColor.whiteColor() {
        didSet { button.bgColor = buttonBGColor }
    }
    @IBInspectable public var buttonBorderWidth : CGFloat = 5.0 {
        didSet { button.borderWidth = buttonBorderWidth }
    }
    
    
    @IBInspectable public var markerBorderColor : UIColor = UIColor.whiteColor()
    @IBInspectable public var markerFontColor : UIColor = UIColor.whiteColor()
    @IBInspectable public var markerDashedLineColor : UIColor = UIColor.whiteColor()
    
    
    
    var view : UIView!
    
    
    func xibSetup() {
        self.backgroundColor = UIColor.clearColor()
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        button.addGestureRecognizer(panGesture)
        buttonStartPoint = button.center
        
        deltaValue = maxValue - minValue
        button.value = 1
        button.maxValue = 1
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.setup()
        }
        
        
        
    }
    
    func setup() {
        self.layoutSubviews()
        tableView.separatorInset = UIEdgeInsetsZero
        button.fontSize = button.frame.size.width/4
        deltaValue = maxValue - minValue
        tableView.reloadData()
        tableView.contentOffset = CGPointMake(0, (tableView.contentSize.height - self.view.frame.size.height)/2)
        currentRatio = 0.5
    }
    
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "DTScrollPickerView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options : nil)[0] as! UIView
        
        return view
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    /* PAN GESTURE HANDLER */
    
    func pan(sender : UIPanGestureRecognizer) {
        let tPoint = sender.locationInView(view)
        
        
        switch sender.state {
        case .Began:
            isPanning = true
            startPoint = tPoint
            buttonStartPoint = button.center
        case .Changed:
            
            let deltaY = tPoint.y - startPoint.y
            let newPoint = CGPointMake(buttonStartPoint.x, buttonStartPoint.y + deltaY)
            
            let cPoint = newPoint.y - (CELL_HEIGHT/2)
            let cHeight = self.view.frame.size.height - CELL_HEIGHT
            var ratio = cPoint / cHeight
            if ratio <= 0 { ratio = 0 }
            if ratio >= 1 { ratio = 1 }
            
            updateWithRatio(ratio)
            currentRatio = ratio
            //button.fontSize = button.frame.size.width/4
            
        case .Ended, .Failed, .Cancelled:
            isPanning = false
            self.startPoint = self.button.center
            sendValueToDelegate()
        default :
            break
        }
        
    }
    
    
    
    /* UITABLEVIEW DATA SOURCE */
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount + 1
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        let actualValue = minValue + (Double(cellCount - indexPath.row) * (deltaValue / Double(cellCount)))
        let valueString = String.localizedStringWithFormat("%.02f", actualValue, "%")
        cell?.textLabel?.text = valueString
        cell?.backgroundColor = UIColor.clearColor()
        cell?.layoutMargins = UIEdgeInsetsZero
        cell?.preservesSuperviewLayoutMargins = false
        return cell!
    }
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    
    /* UITABLEVIEW DELEGATE */
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    /* UISCROLLVIEW DELEGATE*/
  public   
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !isPanning {
            
            let point = scrollView.contentOffset
            let size = scrollView.contentSize
            let screenSize = view.bounds.size
            let actualHeight = size.height - screenSize.height
            let ratio = point.y / actualHeight
            updateWithRatio(ratio)
            currentRatio = ratio
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        sendValueToDelegate()
    }
    
    
    
    /*  CLASS METHODS  */
    
    func sendValueToDelegate() {
        let value = minValue + (Double(1 - currentRatio) * deltaValue)
        if delegate != nil {
            
            delegate?.ScrollPickerViewValueDidChange(self, value: value, unit: unitString!)
        }
        
    }
    
    func updateWithRatio(ratio : CGFloat) {
        let value = minValue + (Double(1 - ratio) * deltaValue)
        let valueString = String.localizedStringWithFormat("%.02f", value, "%")
        button.valueString = valueString
        
        if isPanning {
            tableView.contentOffset = CGPoint(x: 0, y: (ratio * (tableView.contentSize.height - view.frame.size.height)))
        }
        
        
        verticalConstraint.constant = (ratio - 0.5) * (view.frame.size.height - CELL_HEIGHT)
        widthConstraint.constant = ((0.5 - ratio)) * CGFloat(buttonZoomRatio)
        button.setNeedsDisplay()
        button.layoutIfNeeded()
        button.fontSize = button.frame.size.width/4
        tableView.backgroundColor = UIColor.interpolateRGBColorFrom(maxColor, toColor: minColor, ratio: ratio)
    }
    
    
    public func drawMarkers( markers : [DTScrollPickerMarker]?) {
        
        if markers == nil {
            return
        }
        
        for marker in markers! {
            
            
            if marker.value < minValue || marker.value > maxValue {
                return
            }
            
            let ratio = CGFloat((marker.value - minValue) / deltaValue)
            let actualHeight = tableView.contentSize.height - CELL_HEIGHT
            let posY = ((1 - ratio) * actualHeight) + CELL_HEIGHT/2
            let height = view.frame.size.width/4 + ((ratio - 0.5) * buttonZoomRatio)
            
            let bundle = NSBundle(forClass: self.dynamicType)
            let nib = UINib(nibName: "DTScrollMarkerView", bundle: bundle)
            let markerView = nib.instantiateWithOwner(self, options: nil)[0] as! DTScrollMarkerView
            
            markerView.frame = CGRectMake(0, posY - height/2, view.frame.size.width, height)
            markerView.topMarkerLbl.text = marker.topMarker
            markerView.bottomMarkerLbl.text = marker.bottomMarker
            
            markerView.progressView.valueString = "\(marker.value)"
            if unitString != nil {
                markerView.progressView.showUnit = true
                markerView.progressView.valueUnit = unitString!
            }
            markerView.progressView.progressColor = markerBorderColor
            markerView.progressView.fontColor = markerFontColor
            markerView.progressView.fontSize = markerView.progressView.frame.size.width/6
            markerView.progressView.bgColor = UIColor.interpolateRGBColorFrom(maxColor, toColor: minColor, ratio: CGFloat(1 - ratio))
            
            markerView.bottomMarkerLbl.textColor = markerFontColor
            markerView.topMarkerLbl.textColor = markerFontColor
            markerView.dashedLine.lineColor = markerDashedLineColor
            
            tableView.addSubview(markerView)
        }
    }

    
    
    
    
    
    

}