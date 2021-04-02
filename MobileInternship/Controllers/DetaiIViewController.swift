//
//  DetaiIViewController.swift
//  MobileInternship
//
//  Created by Serj on 30.03.2021.
//

import UIKit

class DetaiIViewController: UIViewController {
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    
    var selectedItem: ItemData? 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        dateLabel.text = selectedItem?.dateStart
        timeLabel.text = "\(selectedItem?.timeStart ?? "0.0") - \(selectedItem?.timeFinish ?? "0.0")"
        descriptionText.text = selectedItem?.itemDescription
        itemName.text = selectedItem?.name
    }
}
