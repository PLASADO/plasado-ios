//
//  CalendarTableViewCell.swift
//  plasado
//
//  Created by a on 8/9/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import SwipeCellKit
class CalendarTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var intention_Content: UITextView!
    @IBOutlet weak var intention_Title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
