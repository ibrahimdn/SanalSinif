//
//  new.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 7.11.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit

class newVC: UIViewController {

    var name=""
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text=name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
