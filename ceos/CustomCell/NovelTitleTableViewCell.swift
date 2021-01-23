//
//  NovelTitleTableViewCell.swift
//  ceos
//
//  Created by WEI Shih Yen on 2017/7/18.
//
//

import UIKit

class NovelTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var offlineBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
