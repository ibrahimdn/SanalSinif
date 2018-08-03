//
//  duyuruCell.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 22.02.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit

class duyuruCell: UITableViewCell {

    
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var baslikLabel: UILabel!
    @IBOutlet weak var aciklamaLabel: UILabel!
    @IBOutlet weak var dosyaAdiLabel: UILabel!
    @IBOutlet weak var resimView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        baslikLabel.sizeToFit()
        baslikLabel.textAlignment = NSTextAlignment.center
        baslikLabel.lineBreakMode = .byTruncatingTail
        baslikLabel.numberOfLines = 2
        aciklamaLabel.sizeToFit()
        aciklamaLabel.adjustsFontSizeToFitWidth = true
        aciklamaLabel.numberOfLines = 0
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
