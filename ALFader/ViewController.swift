//
//  ViewController.swift
//  ALFader
//
//  Created by Mac on 23.10.2017.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let fader = Fader(frame: UIScreen.main.bounds.insetBy(dx: 32, dy: UIScreen.main.bounds.height / 2.3))
        fader.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.addSubview(fader)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
