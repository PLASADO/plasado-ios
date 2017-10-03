//
//  MyIntentionCell.swift
//  plasado
//
//  Created by a on 8/6/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit

class MyIntentionCell: UITableViewCell {

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
