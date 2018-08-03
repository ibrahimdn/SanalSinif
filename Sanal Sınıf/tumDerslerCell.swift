//
//  tumDerslerCell.swift
//  
//
//  Created by ibrahim on 21.11.2017.
//
//

import UIKit

class tumDerslerCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var takipLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var okulBolumLabel: UILabel!
    @IBOutlet var dersinAdıLabel: UILabel!
    @IBOutlet var dersinOgrtLabel: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
