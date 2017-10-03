//
//  OfferCell.swift
//  plasadoapp
//
//  Created by a on 8/13/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit

protocol DeailsButtonDelegate {
    func onDetailButtonClicked(num : Int!)
}
class OfferCell: UITableViewCell {
    
    
    @IBOutlet weak var offerImage: UIImageView!
    
    @IBOutlet weak var offerTitle: UILabel!
    
    @IBOutlet weak var discount: UILabel!
    
    var delegate : DeailsButtonDelegate!
    
    var index : Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onDetail(_ sender: Any) {
        delegate.onDetailButtonClicked(num: self.index)
    }
}
