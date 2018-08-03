//
//  odevKontrolCell.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 21.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit

protocol cellDelegate {
    func didodevClicked(cell:UITableViewCell)
  
}

class odevKontrolCell: UITableViewCell {
  
    var delegate :cellDelegate?
    
    @IBOutlet weak var dosyAdiLabel: UILabel!
   
    @IBOutlet weak var ogrenciAdiLabel: UILabel!
    @IBOutlet weak var odevClicked: UIButton!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func odevClicked(_ sender: UIButton) {
       print("odev Clicked")
        delegate?.didodevClicked(cell: self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
