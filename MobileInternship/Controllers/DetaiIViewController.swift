//
//  DetaiIViewController.swift
//  MobileInternship
//
//  Created by Serj on 30.03.2021.
//

import UIKit

class DetaiIViewController: UIViewController {
    
    var selectedItem: ItemData? {
        didSet {
            print(selectedItem?.name)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
