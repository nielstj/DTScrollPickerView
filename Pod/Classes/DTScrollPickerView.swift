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
    
    
    
    
    
    @IBInspectable public var cellCount = 30 {
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
            button.showUnit = true
            button.valueString = unitString!
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var buttonBGColor : UIColor = UIColor.whiteColor() {
        didSet {
            button.borderColor = buttonBGColor
            button.setNeedsDisplay()
        }
    }
    
    
    
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
        deltaValue = maxValue - minValue
        tableView.reloadData()
        tableView.contentOffset = CGPointMake(0, (tableView.contentSize.height - self.view.frame.size.height)/2)
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
            
            //button.center = newPoint
            
            let maxRadius = ((view.frame.size.width/4 + buttonZoomRatio/2) / 2)
            let minRadius = ((view.frame.size.width/4 - buttonZoomRatio/2) / 2)
            
            let cPoint = newPoint.y - maxRadius
            let cHeight = self.view.frame.size.height - maxRadius - minRadius
            var ratio = cPoint / cHeight
            
            //print("Ratio first : \(ratio)")
            
            if ratio <= 0 { ratio = 0 }
            if ratio >= 1 { ratio = 1 }
            
            //print("Ratio first : \(ratio)")
            
            let value = minValue + (Double(1 - ratio) * deltaValue)
            let valueString = String.localizedStringWithFormat("%.02f", value, "%")
            button.valueString = valueString
            
            tableView.contentOffset = CGPoint(x: 0, y: (ratio * (tableView.contentSize.height - view.frame.size.height)))
            
            
            verticalConstraint.constant = (ratio - 0.5) * (view.frame.size.height - button.frame.size.width)
            widthConstraint.constant = ((0.5 - ratio)) * CGFloat(buttonZoomRatio)
            button.setNeedsDisplay()
            button.layoutIfNeeded()
            
            tableView.backgroundColor = UIColor.interpolateRGBColorFrom(maxColor, toColor: minColor, ratio: ratio)
            
        case .Ended, .Failed, .Cancelled:
            isPanning = false
            self.startPoint = self.button.center
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
            let value = minValue + deltaValue - (Double(ratio) * deltaValue)
            let valueString = String.localizedStringWithFormat("%.02f", value, "%")
            button.valueString = valueString
            
            button.setNeedsDisplay()
            verticalConstraint.constant = (ratio - 0.5) * (view.frame.size.height - button.frame.size.width)
            widthConstraint.constant = ((0.5 - ratio)) * CGFloat(buttonZoomRatio)
            button.layoutIfNeeded()
            
            tableView.backgroundColor = UIColor.interpolateRGBColorFrom(maxColor, toColor: minColor, ratio: ratio)
        }
    }
    
    
    
    
    

}