//
//  ProfileSearchCell.swift
//  plasado
//
//  Created by a on 8/6/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit

class ProfileSearchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(with searchTerm:String, cellText:String)
    {
        // Create a regEx pattern
        var pattern = searchTerm.replacingOccurrences(of: " ", with: "|")
        pattern.insert("(", at: pattern.startIndex)
        pattern.insert(")", at: pattern.endIndex)
        
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .allowCommentsAndWhitespace])
            let range = NSRange(location: 0, length: cellText.characters.count)
            let displayString = NSMutableAttributedString(string: cellText)
            let highlightColour = UIColor(colorLiteralRed: 124/255.0, green: 215/255.0, blue: 204/255.0, alpha: 0.5)
            
            regEx.enumerateMatches(in: cellText, options: .withTransparentBounds, range: range, using: { (result, flags, stop) in
                
                if result?.range != nil
                {
                    displayString.setAttributes([NSBackgroundColorAttributeName:highlightColour], range: result!.range)
                }
                
            })
            
            self.textLabel?.attributedText = displayString
            
        } catch
        {
            self.textLabel?.text = cellText
        }
    }

}
