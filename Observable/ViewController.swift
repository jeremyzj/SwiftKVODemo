//
//  ViewController.swift
//  Observable
//
//  Created by magi on 2019/10/25.
//  Copyright © 2019 magi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var x = Observable(0)
        x.afterChange += { print("Changed x from \($0) to \($1)") }
        
        x.afterChange += { [weak self] _ in self?.afterChange() }
        
        x <- 42
    }
    
    func afterChange() {
        print("afterChange")
    }


}

