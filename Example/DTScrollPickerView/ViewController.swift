//
//  ViewController.swift
//  DTScrollPickerView
//
//  Created by Daniel Tjuatja on 12/28/2015.
//  Copyright (c) 2015 Daniel Tjuatja. All rights reserved.
//

import UIKit
import DTScrollPickerView

class ViewController: UIViewController, DTScrollPickerViewDelegate {

    @IBOutlet weak var scrollPicker : DTScrollPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollPicker.delegate = self
        
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
    }
    
}

