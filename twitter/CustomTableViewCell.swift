//
//  CustomTableViewCell.swift
//  twitter
//
//  Created by McTavish Wang on 15/12/29.
//  Copyright © 2015年 McTavish Wang. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customText: UILabel!
    @IBOutlet weak var status: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        customImage.layer.masksToBounds = true
        customImage.layer.cornerRadius = customImage.frame.size.width/2
        customView.layer.masksToBounds = true
        customView.layer.cornerRadius = 10
        status.layer.masksToBounds = true
        status.layer.cornerRadius = status.frame.size.width/2
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
