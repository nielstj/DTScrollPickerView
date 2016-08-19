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
        
        let markers = [DTScrollPickerMarker(val : 0.1, top : "abc", bottom : "def"),
            DTScrollPickerMarker(val : 0.8, top : "abc", bottom : "def")]
        
        
        DispatchQueue.main.async { () -> Void in
           
            self.scrollPicker.minValue = 0
            self.scrollPicker.maxValue = 1.0
            
            self.scrollPicker.drawMarkers(markers)
            //self.scrollPicker.updateScrollWithValue(0.2)
            self.scrollPicker.updateScrollWithValue(0.2, animated: true)
            print(self.scrollPicker.currentValue)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func ScrollPickerViewValueDidChange(_ scrollPicker: DTScrollPickerView, value: Double, unit: String?) {
        // do something
        
        print("value : \(value) unit : \(unit)")
        
        
        
        
    }
    
}

