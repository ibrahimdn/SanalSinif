//
//  gruplarVC.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 14.05.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@available(iOS 10.0, *)
class gruplarVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var mesajlar = [sohbet]()
    var dersId = String()
    var dersAdi = String()
    var ogretmenID = String()
    var kullaniciAdi : String = ""
    
    @IBOutlet weak var sohbetTable: UITableView!
    @IBOutlet weak var baslikDersAdi: UINavigationItem!
    @IBOutlet weak var mesajText: UITextField!
    @IBOutlet weak var gonderButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sohbetTable.delegate = self
        sohbetTable.dataSource = self
        baslikDersAdi.title = dersAdi
        gelendata()
        gelenMesajlar()
    }

    @IBAction func geriClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func gelenMesajlar() {
      
        if ogretmenID != "" && dersId != "" {
        Database.database().reference().child("kullanicilar").child(ogretmenID).child("derslerim").child(dersId).child("sohbet").queryOrdered(byChild: "time").observe(.value, with: { (DataSnapshot) in
                self.mesajlar.removeAll()
                if (DataSnapshot.value as? NSDictionary) != nil {
                    
                    let value = DataSnapshot.value as! NSDictionary
                    let valuekey = value.allKeys
                    for key in valuekey {
                        if let sohbetler = value[key] as? NSDictionary {
                       
                            let kullaniciID = sohbetler["kullaniciID"] as! String
                            
                            let sohbetBilgi = sohbet(kullaniciID: kullaniciID, mesajData: value[key] as! [String :AnyObject])
                            self.mesajlar.insert(sohbetBilgi, at: 0)
                          
                       
                        }
                    }
                }
           
            self.sohbetTable.reloadData()
            let indexpath = IndexPath(row: self.mesajlar.count - 1, section: 0)
            self.sohbetTable.scrollToRow(at: indexpath , at: .bottom, animated: true)
            })
           
            
        }
    }
    func gelendata() {

        Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).observe(.childAdded, with: { (snapshot) in
             let kulVeri = snapshot.value! as! NSDictionary
            if kulVeri["ad"] as? String != nil {
                self.kullaniciAdi = kulVeri["ad"] as! String
                print(self.kullaniciAdi)
          
             }
        })
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mesajlar.count >  1 {
           self.mesajlar.sort(by: { $0.tarih < $1.tarih })
          
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sohbetCell", for: indexPath) as! sohbetCell
        if mesajlar[indexPath.row].kullaniciId == Auth.auth().currentUser?.uid {
            cell.sohbetLabel.textAlignment = .right
            cell.isimLabel.isHidden = true
        }else {
            cell.sohbetLabel.textAlignment = .left
            cell.isimLabel.isHidden = false
        }
        cell.mesajlar(sohbet: mesajlar[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return mesajlar.count
    }
    @IBAction func gonderButton(_ sender: Any) {
        if mesajText.text != "" {
            let mesaj = ["ad" : kullaniciAdi,
                         "time" : getTarih(),
                         "kullaniciID" : (Auth.auth().currentUser?.uid)!,
                         "mesaj": mesajText.text!] as [String : Any]
            Database.database().reference().child("kullanicilar").child(ogretmenID).child("derslerim").child(dersId).child("sohbet").childByAutoId().setValue(mesaj)
        }
        sohbetTable.reloadData()
    
        mesajText.text = ""
    }
    func getTarih() -> String {
        let vc : duyuruEkleVC = duyuruEkleVC(nibName: nil, bundle: nil)
        return vc.tarih()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }

}
