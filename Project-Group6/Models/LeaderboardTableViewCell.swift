//
//  LeaderboardTableViewCell.swift
//  Project-Group6
//
//  Created by Sophie School on 2026-07-30.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    
    @IBOutlet var lblRank: UILabel!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblScore: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
