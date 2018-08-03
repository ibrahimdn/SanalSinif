//
//  sohbetCell.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 14.05.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit

class sohbetCell: UITableViewCell {

    
 
    @IBOutlet weak var sohbetLabel: UILabel!
    @IBOutlet weak var isimLabel: UILabel!
    
    @IBOutlet weak var viewCell: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func mesajlar (sohbet: sohbet){
        isimLabel.text = sohbet.isim
        sohbetLabel.text = sohbet.mesaj
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
