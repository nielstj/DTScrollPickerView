//
//  ViewController.swift
//  DTScrollPickerView
//
//  Created by Daniel Tjuatja on 12/28/2015.
//  Copyright (c) 2015 Daniel Tjuatja. All rights reserved.
//

import UIKit
import DTScrollPickerView

class ViewController: UIViewController {

    @IBOutlet weak var scrollPicker : DTScrollPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //scrollPicker.button.bgColor = UIColor.whiteColor()
        scrollPicker.button.borderColor = UIColor.greenColor()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

