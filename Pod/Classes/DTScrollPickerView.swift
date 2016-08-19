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
    
    public init(val : Double, top : String, bottom : String) {
        value = val
        bottomMarker = bottom
        topMarker = top
    }
    
    var value : Double = 0.0
    var topMarker = ""
    var bottomMarker = ""
}

public protocol DTScrollPickerViewDelegate : class {
    func ScrollPickerViewValueDidChange(_ scrollPicker : DTScrollPickerView, value : Double, unit : String?)
}


public class DTScrollMarkerView: UIView {
    
    @IBOutlet public weak var topMarkerLbl : UILabel!
    @IBOutlet public weak var bottomMarkerLbl : UILabel!
    @IBOutlet public weak var progressView : DTCircleProgressView!
    @IBOutlet public weak var dashedLine : DTDashedLineView!
    
}



@IBDesignable
public class DTScrollPickerView: UIView, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet public var button : DTCircleProgressView!
    
    
    @IBOutlet weak var verticalConstraint : NSLayoutConstraint!
    @IBOutlet weak var widthConstraint : NSLayoutConstraint!
    
    
    
    var isPanning = false
    
    var startPoint : CGPoint = CGPoint(x: 0, y: 0)
    var buttonStartPoint : CGPoint = CGPoint(x: 0, y: 0)
    var deltaValue : Double = 0.0
    var currentRatio : CGFloat = 0.0
    public var delegate : DTScrollPickerViewDelegate?
    
    
    
    
    @IBInspectable public var cellCount : Int = 30 {
        didSet {
            DispatchQueue.main.async { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    @IBInspectable public var minValue : Double = 0.0 {
        didSet {
            self.updateTable()
        }
    }
    
    @IBInspectable public var maxValue : Double = 0.0 {
        didSet {
            self.updateTable()
        }
    }
    
    
    @IBInspectable public var decimals : Int = 1 {
        didSet {
            self.updateTable()
        }
    }
    
    
    @IBInspectable public var buttonZoomRatio : CGFloat = 50.0 {
        didSet {
            self.updateTable()
        }
    }
    
    
    @IBInspectable public var CELL_HEIGHT : CGFloat  = 100 {
        didSet {
            self.updateTable()
        }
    }
    
    
    @IBInspectable public var valueColor : UIColor = UIColor.black
    
    @IBInspectable public var maxColor : UIColor = UIColor.clear {
        didSet {
            self.updateTable()
        }
    }
    
    @IBInspectable public var minColor : UIColor = UIColor.clear {
        didSet {
            self.updateTable()
        }
    }
    
    @IBInspectable public var unitString : String? {
        didSet {
            if unitString != nil {
                button.showUnit = true
                button.valueUnit = unitString!
                self.updateTable()
            }
        }
    }
    
    
    
    
    @IBInspectable public var buttonFontColor : UIColor = UIColor.white {
        didSet  { button.fontColor = buttonFontColor }
    }
    @IBInspectable public var buttonFontName : String = "HelveticaNeue" {
        didSet { button.fontName = buttonFontName }
    }
    @IBInspectable public var buttonBorderColor : UIColor = UIColor.blue {
        didSet { button.borderColor = buttonBorderColor }
    }
    @IBInspectable public var buttonProgressColor : UIColor = UIColor.purple {
        didSet { button.progressColor = buttonProgressColor }
    }
    @IBInspectable public var buttonBorderAlpha : CGFloat = 1.0 {
        didSet { button.borderAlpha = buttonBorderAlpha }
    }
    @IBInspectable public var buttonBGColor : UIColor = UIColor.white {
        didSet { button.bgColor = buttonBGColor }
    }
    @IBInspectable public var buttonBorderWidth : CGFloat = 5.0 {
        didSet { button.borderWidth = buttonBorderWidth }
    }
    
    
    @IBInspectable public var markerBorderColor : UIColor = UIColor.white
    @IBInspectable public var markerFontColor : UIColor = UIColor.white
    @IBInspectable public var markerDashedLineColor : UIColor = UIColor.white
    
    
    public var currentValue : Double {
        get {
            return minValue + (Double(1 - currentRatio) * deltaValue)
        }
    }
    
    
    
    
    
    var view : UIView!
    
    
    func xibSetup() {
        self.backgroundColor = UIColor.clear
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        button.addGestureRecognizer(panGesture)
        buttonStartPoint = button.center
        
        deltaValue = maxValue - minValue
        button.value = 1
        button.maxValue = 1
        DispatchQueue.main.async { () -> Void in
            self.setup()
        }
        
        
        
    }
    
    
    
    func setup() {
        self.layoutSubviews()
        tableView.separatorInset = UIEdgeInsets.zero
        button.fontSize = button.frame.size.width/4
        deltaValue = maxValue - minValue
        tableView.reloadData()
        tableView.contentOffset = CGPoint(x: 0, y: (tableView.contentSize.height - self.view.frame.size.height)/2)
        currentRatio = 0.5
    }
    
    public func updateTable() {
        deltaValue = maxValue - minValue
        tableView.contentOffset = CGPoint(x: 0, y: (tableView.contentSize.height - self.view.frame.size.height)/2)
        self.tableView.reloadData()
        self.updateScrollWithValue(self.currentValue, animated:false)
    }
    
    
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DTScrollPickerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options : nil)[0] as! UIView
        
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
    
    func pan(_ sender : UIPanGestureRecognizer) {
        let tPoint = sender.location(in: view)
        
        
        switch sender.state {
        case .began:
            isPanning = true
            startPoint = tPoint
            buttonStartPoint = button.center
        case .changed:
            
            let deltaY = tPoint.y - startPoint.y
            let newPoint = CGPoint(x: buttonStartPoint.x, y: buttonStartPoint.y + deltaY)
            
            let cPoint = newPoint.y - (CELL_HEIGHT/2)
            let cHeight = self.view.frame.size.height - CELL_HEIGHT
            var ratio = cPoint / cHeight
            if ratio <= 0 { ratio = 0 }
            if ratio >= 1 { ratio = 1 }
            
            updateWithRatio(ratio)
            currentRatio = ratio
            //button.fontSize = button.frame.size.width/4
            
        case .ended, .failed, .cancelled:
            isPanning = false
            self.startPoint = self.button.center
            sendValueToDelegate()
        default :
            break
        }
        
    }
    
    
    
    /* UITABLEVIEW DATA SOURCE */
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount + 1
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        let actualValue = minValue + (Double(cellCount - (indexPath as NSIndexPath).row) * (deltaValue / Double(cellCount)))
        let valueString = String.localizedStringWithFormat("%.0\(decimals)f", actualValue, "%")
        cell?.textLabel?.text = valueString
        cell?.textLabel?.textColor = valueColor
        cell?.backgroundColor = UIColor.clear
        cell?.layoutMargins = UIEdgeInsets.zero
        cell?.preservesSuperviewLayoutMargins = false
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    
    /* UITABLEVIEW DELEGATE */
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    /* UISCROLLVIEW DELEGATE*/
  public   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sendValueToDelegate()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            sendValueToDelegate()
        }
    }
    
    
    /*  CLASS METHODS  */
    
    func sendValueToDelegate() {
        let value = minValue + (Double(1 - currentRatio) * deltaValue)
        if delegate != nil {
            delegate?.ScrollPickerViewValueDidChange(self, value: value, unit: unitString)
        }
    }
    
    public func updateScrollWithValue(_ newValue : Double, animated : Bool) {
        if newValue < maxValue && newValue > minValue {
            isPanning = true
            let ratio = CGFloat((newValue - minValue) / deltaValue)
            currentRatio =  1 - ratio
            if animated {
                let size = tableView.contentSize
                let screenSize = view.bounds.size
                let actualHeight = size.height - screenSize.height
                let currentHeight = currentRatio * actualHeight
                tableView.setContentOffset(CGPoint(x: 0,y: currentHeight), animated: true)
            }
            else {
                updateWithRatio(currentRatio)
            }
            isPanning = false
        }
    }
    
    
    func updateWithRatio(_ ratio : CGFloat) {
        let value = minValue + (Double(1 - ratio) * deltaValue)
        let valueString = String.localizedStringWithFormat("%.0\(decimals)f", value, "%")
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
    
    
    public func drawMarkers( _ markers : [DTScrollPickerMarker]?) {
        
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
            
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "DTScrollMarkerView", bundle: bundle)
            let markerView = nib.instantiate(withOwner: self, options: nil)[0] as! DTScrollMarkerView
            
            markerView.frame = CGRect(x: 0, y: posY - height/2, width: view.frame.size.width, height: height)
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
