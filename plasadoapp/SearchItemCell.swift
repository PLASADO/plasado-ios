//
//  SearchItemCell.swift
//  plasadoapp
//
//  Created by Emperor on 8/30/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit

class SearchItemCell: UITableViewCell {

    @IBOutlet var userImage: UIImageView!
    
    @IBOutlet var name: UILabel!
    
    var index : Int = 0;
    
    @IBOutlet weak var addButton: UIButton!
    
    var delegate : UserAddDelegate!
    
    @IBAction func onadd(_ sender: Any) {
        delegate.onUserAdded(num: index)
        
        
        /*if (added == false){
            addButton.setImage(UIImage(named:"checked"), for: .normal)
            added = true
        }*/
        
    }
    func onAddedUser(){
        self.addButton.setImage(UIImage(named:"checked"), for: .normal)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addButton.setImage(UIImage(named:"plus1"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        userImage.image = nil
        name.text = ""
    }
    func setText(str : String){
        name.text = str
    }
    func setIndex(num : Int){
        index = num
    }
    func setImage(url : String){
        
        userImage.sd_setImage(with: URL(string :  url)) { (image, err, type, url) in
            self.setNeedsLayout()
        }
    }
}
