//
//  TypeTableViewCell.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/7/17.
//
//

import UIKit

class TypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
