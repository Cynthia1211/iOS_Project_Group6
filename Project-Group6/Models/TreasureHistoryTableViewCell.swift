//
//  TreasureHistoryTableViewCell.swift
//  Project-Group6
//
//  Created by Alexander Tumanan on 2026-08-01.
//

import UIKit

// Displays one treasure row on the My Treasures screen.
class TreasureHistoryTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!   // Treasure title
    @IBOutlet var lblStatus: UILabel!  // Points and found status

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
