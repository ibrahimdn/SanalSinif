//
//  duyuruCell2.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 8.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
protocol cell2delegate {
    
    func dosyaAdButton(cell: UITableViewCell)
}

class duyuruCell2: UITableViewCell {
    
    @IBOutlet weak var starpng: UIImageView!
    var delegate:cell2delegate?
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var baslikLabel: UILabel!
    
    @IBOutlet weak var ogretmenLabel: UILabel!
    @IBOutlet weak var dosyaAdButton: UIButton!
    @IBOutlet weak var duyuruResim: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var view: UIView!
    @IBAction func dosyaAdButton(_ sender: Any) {
        print("cell2 tuş")
        print(dosyaAdButton.tag)
        delegate?.dosyaAdButton(cell: self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
