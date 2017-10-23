//
//  ViewController.swift
//  ALFader
//
//  Created by Mac on 23.10.2017.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FaderDelegate {
    let label1 = UILabel()
    let label2 = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label1.frame = CGRect(x: 0, y: 0, width: 400, height: 50)
        label2.frame = CGRect(x: 0, y: 50, width: 400, height: 50)
        let fader = Fader(frame: UIScreen.main.bounds.insetBy(dx: 32, dy: UIScreen.main.bounds.height / 2.3))
        fader.delegate = self
        view.addSubview(fader)
        view.addSubview(label1)
        view.addSubview(label2)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func rangeDidChage(left: CGFloat, right: CGFloat) {
        label1.text = "Left Value:\(left)"
        label2.text = "Right value: \(right)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
