//
//  ItemCell.swift
//  MobileInternship
//
//  Created by Serj on 27.03.2021.
//

import UIKit

class ItemCell: UITableViewCell {

    
    @IBOutlet weak var timeBackground: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeBackground.layer.cornerRadius = timeBackground.frame.size.height / 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
