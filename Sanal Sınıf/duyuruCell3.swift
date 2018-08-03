//
//  duyuruCell3.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 8.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
protocol cell3delegate {
    
    func dosyaAdButton(cell: UITableViewCell)
}


class duyuruCell3: UITableViewCell {

    @IBOutlet weak var starpng: UIImageView!
    @IBOutlet weak var ogretmenLabel: UILabel!
    @IBOutlet weak var arkaplanCard: UIView!
    var delegate:cell3delegate?
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var baslikLabel: UILabel!
    @IBOutlet weak var dosyaAdButton: UIButton!
    @IBOutlet weak var aciklamaLabel: UILabel!
    @IBOutlet weak var duyuruResim: UIImageView!
    

    
    @IBAction func dosyaAdButton(_ sender: Any) {
        print("cell3 tuş")
        print(dosyaAdButton.tag)
        delegate?.dosyaAdButton(cell: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
