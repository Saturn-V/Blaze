//
//  DirectionTableViewCell.swift
//  Cycl
//
//  Created by Miriam Hendler on 12/27/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import UIKit

class DirectionTableViewCell: UITableViewCell {

    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var directionDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
