//
//  OfferDetailHeaderCell.swift
//  plasadoapp
//
//  Created by Emperor on 8/29/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit

class OfferDetailHeaderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var offerTitle: UILabel!
    
    @IBOutlet weak var offerComment: UITextView!
    
    @IBOutlet weak var offerPrice1: UILabel!
    
    @IBOutlet weak var offerPrice2: UILabel!
    
    @IBAction func buynow(_ sender: Any) {
    }
    
}
