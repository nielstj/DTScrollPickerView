//
//  ViewController.swift
//  DTScrollPickerView
//
//  Created by Daniel Tjuatja on 12/28/2015.
//  Copyright (c) 2015 Daniel Tjuatja. All rights reserved.
//

import UIKit
import DTScrollPickerView
//import DTScrollPickerMarker

class ViewController: UIViewController, DTScrollPickerViewDelegate {

    @IBOutlet weak var scrollPicker : DTScrollPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollPicker.delegate = self
        
        let markers = [DTScrollPickerMarker(val : 10.0, top : "abc", bottom : "def"),
            DTScrollPickerMarker(val : 30.0, top : "abc", bottom : "def"),
            DTScrollPickerMarker(val : 40.0, top : "abc", bottom : "def")]
        
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.scrollPicker.drawMarkers(markers)
            self.scrollPicker.updateScrollWithValue(80)
            print(self.scrollPicker.currentValue)
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func ScrollPickerViewValueDidChange(scrollPicker: DTScrollPickerView, value: Double, unit: String?) {
        // do something
        
        print("value : \(value) unit : \(unit)")
        
        
        
        
    }
    
}

