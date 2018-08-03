//
//  duyuruCell1.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 8.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
protocol cell1delegate {
    
    func dosyaAdButton(cell: UITableViewCell)
}

class duyuruCell1: UITableViewCell {
    var delegate: cell1delegate?
    @IBOutlet weak var baslikLabel: UILabel!
    @IBOutlet weak var starpng: UIImageView!
    @IBOutlet weak var dosyaAdButton: UIButton!
    @IBOutlet weak var aciklamaLabel: UILabel!
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var ogretmenLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func dosyaAdButton(_ sender: Any) {
        print("cell1 tuş")
        print(dosyaAdButton.tag)
        delegate?.dosyaAdButton(cell: self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
