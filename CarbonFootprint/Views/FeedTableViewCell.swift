//
//  FeedTableViewCell.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 19.03.2023.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
