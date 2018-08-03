//
//  ogrenciKontrolCell.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 11.05.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit

class ogrenciKontrolCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var isimLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func customInit(text: String, accessoryText: String){
        self.isimLabel.text = text
        
    }
}
