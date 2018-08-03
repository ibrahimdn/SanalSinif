//
//  tumDerslerVC.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 5.11.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@available(iOS 10.0, *)
class tumDerslerVC: UIViewController, UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet var dersTablosu: UITableView!
    @IBOutlet weak var aramaBar: UISearchBar!
    
    var dersinAdi = [String]()
    var dersinBolumu = [String]()
    var dersinOkulu = [String]()
    var dersinOgrt = [String]()
    var dersinSifresi = [String]()
    var dersID = [String] ()
    var ogretmenId = [String]()
    var arama = [String]()
    var isarama = false
    var isarama2 = false
    var refreshControl: UIRefreshControl!
    var aramaSonucIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dersTablosu.delegate = self
        dersTablosu.dataSource = self
        aramaBar.delegate = (self as UISearchBarDelegate)
        aramaBar.returnKeyType = UIReturnKeyType.done
        dersTablosu.tableFooterView = UIView()
        
        butunVeri()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(tumDerslerVC.butunVeri), for: UIControlEvents.valueChanged)
        dersTablosu.addSubview(refreshControl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.addObserver( self, selector: #selector(tumDerslerVC.butunVeri), name: NSNotification.Name(rawValue: "dersEkleme"), object: nil)
        //butunVeri()
    }
    
    func butunVeri(){
        self.dersID.removeAll()
        self.dersinOgrt.removeAll()
        self.dersinAdi.removeAll()
        self.dersinOkulu.removeAll()
        self.dersinBolumu.removeAll()
        self.dersinSifresi.removeAll()
        self.ogretmenId.removeAll()
        
        Database.database().reference().child("kullanicilar").observe(.childAdded, with: { (DataSnapshot) in
            
            let values = DataSnapshot.value as! NSDictionary
            if values["derslerim"] != nil {
                let ders = values["derslerim"] as! NSDictionary
                let  dersid = ders.allKeys
                for id in dersid {
                    
                    let ders = ders[id] as! NSDictionary
                    if let dersbilgisi = ders["dersBilgisi"] as? NSDictionary {
                        self.dersID.append(id as! String)
                        self.dersinOgrt.append(dersbilgisi["ögretmen"] as! String)
                        self.dersinAdi.append(dersbilgisi["adi"]! as! String)
                        self.dersinOkulu.append(dersbilgisi["okulu"] as! String)
                        self.dersinBolumu.append(dersbilgisi["Bolumu"] as! String)
                        self.dersinSifresi.append(dersbilgisi["sifre"] as! String)
                        self.ogretmenId.append(dersbilgisi["ogretmenId"] as! String)
                    }
                }
              
                self.refreshControl.endRefreshing()
                self.dersTablosu.reloadData()
            }
        })
        /*Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").observe(.childAdded, with: { (DataSnapshot) in
            let values = DataSnapshot.value as! NSDictionary
            if let value = values["dersBilgisi"] as? NSDictionary {
                if self.dersID[indexPath.row] == value["ID"] as? String {
                    self.dersinAdi.remove(at: indexPath.row)
                    self.dersinOgrt.remove(at: indexPath.row)
                    self.dersinBolumu.remove(at: indexPath.row)
                }else {
                }
            }
        })*/
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isarama {
            return arama.count
        }
        return dersinAdi.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var dersBilgi = [String : String]()
        if self.isarama == false || self.isarama2 == false {
            dersBilgi = ["ID" : self.dersID[indexPath.row],
                         "Adi" :  self.dersinAdi[indexPath.row],
                         "Öğretmen" :  self.dersinOgrt[indexPath.row],
                         "ogretmenId" :  self.ogretmenId[indexPath.row]]
        }else if self.isarama == true {
            print("arama açık")
            dersBilgi = ["ID" : self.dersID[aramaSonucIndex[0]],
                         "Adi" :  self.dersinAdi[aramaSonucIndex[0]],
                         "Öğretmen" :  self.dersinOgrt[aramaSonucIndex[0]],
                         "ogretmenId" :  self.ogretmenId[aramaSonucIndex[0]]]
        }
    

        let kaydet = UITableViewRowAction(style: .default, title: "Ekle") { (action, index) in
            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).observe(.childAdded, with: { (DataSnapshot) in
                if self.isarama == false {
                    
                    if self.dersinSifresi[indexPath.row] as? String == "" {
                    
                        if DataSnapshot.hasChild(self.dersID[index.row]){
                            let alert = UIAlertController(title: "", message: "Ders ekli.", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }else {
                            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").child(self.dersID[index.row]).child("dersBilgisi").setValue(dersBilgi)
                            let alert = UIAlertController(title: "", message: "Ders eklendi.", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
              
                    } else {
                        let alert = UIAlertController(title: "Dersin Şifresi ", message: "", preferredStyle: .alert)
                        _=alert.addTextField { (UITextField) in
                        UITextField.placeholder = "Dersin Şifresi"
                        }
                    
                        let sifre = alert.textFields?[0]
                    
                        let alertEkle = UIAlertAction(title: "Ekle", style: .default) { (UIAlertAction) in
                        
                            if (alert.textFields?.isEmpty)!  {
                                self.view.makeToast("Şifre boş bırakılamaz")
                            }
                            if self.dersinSifresi[indexPath.row] == sifre?.text {
                            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").child(self.dersID[index.row]).child("dersBilgisi").setValue(dersBilgi)
                            
                            }
                        }
                        alert.addAction(alertEkle)
                        self.present(alert, animated: true, completion: nil)
                    }
                }else {  //arama açık ise
                    if self.dersinSifresi[self.aramaSonucIndex[0]] as? String == "" {
                        
                        if DataSnapshot.hasChild(self.dersID[index.row]){
                            let alert = UIAlertController(title: "", message: "Ders ekli.", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }else {
                            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").child(self.dersID[self.aramaSonucIndex[0]]).child("dersBilgisi").setValue(dersBilgi)
                            let alert = UIAlertController(title: "", message: "Ders eklendi.", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    } else {
                        let alert = UIAlertController(title: "Dersin Şifresi ", message: "", preferredStyle: .alert)
                        _=alert.addTextField { (UITextField) in
                            UITextField.placeholder = "Dersin Şifresi"
                        }
                        
                        let sifre = alert.textFields?[0]
                        
                        let alertEkle = UIAlertAction(title: "Ekle", style: .default) { (UIAlertAction) in
                            
                            if (alert.textFields?.isEmpty)!  {
                                self.view.makeToast("Şifre boş bırakılamaz")
                            }
                            if self.dersinSifresi[indexPath.row] == sifre?.text {
                                Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").child(self.dersID[index.row]).child("dersBilgisi").setValue(dersBilgi)
                                
                            }
                        }
                        alert.addAction(alertEkle)
                        self.present(alert, animated: true, completion: nil)
                    }

                }
            })
          }
        
        let sil = UITableViewRowAction(style: .normal, title: "Kaldır") { (action, index) in
            self.butunVeri()
            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).observe(.childAdded, with: { (DataSnapshot) in
                
                if DataSnapshot.hasChild(self.dersID[indexPath.row]){
                    Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").child(self.dersID[indexPath.row]).removeValue()
                    let alert = UIAlertController(title: "", message: "Ders silindi", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    let alert = UIAlertController(title: "", message: "Ders bulunamadı.", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        return [kaydet,sil]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //dequeueReusableCell => tabloda kullanılan cellerin tekrar kullanılması için kullanılır.ram daha az kullanılmış olur
        let cell = dersTablosu.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! tumDerslerCell
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        if isarama {
            for sonuc in aramaSonucIndex {
                
                cell.dersinAdıLabel.text = dersinAdi[sonuc].uppercased(with:Locale(identifier: "tr"))
                cell.dersinOgrtLabel.text = dersinOgrt[sonuc].capitalized
                cell.okulBolumLabel.text = dersinOkulu[sonuc].capitalized + " & " + dersinBolumu[aramaSonucIndex[0]].capitalized
                isarama = false
            }
        } else if isarama2{
            cell.dersinOgrtLabel.text = dersinOgrt[0].capitalized
            cell.okulBolumLabel.text = dersinOkulu[0].capitalized + " & " + dersinBolumu[0].capitalized
            cell.dersinAdıLabel.text = dersinAdi[0].uppercased(with:Locale(identifier: "tr"))
            for index in aramaSonucIndex {
                print(index)
                print(dersinAdi[index])
                print(dersinOgrt[index])
                print(dersinOkulu[index])
          
            cell.dersinOgrtLabel.text = dersinOgrt[index].capitalized
            cell.okulBolumLabel.text = dersinOkulu[index].capitalized + " & " + dersinBolumu[index].capitalized
                  cell.dersinAdıLabel.text = dersinAdi[index].uppercased(with:Locale(identifier: "tr"))
                
                isarama2 = false
            }
        }
        else {
            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").observe(.value, with: { (DataSnapshot) in
                print(DataSnapshot)
               if  DataSnapshot.hasChild(self.dersID[indexPath.row]){
                    cell.cellView.backgroundColor = UIColor.lightGray
               
               } else {
                cell.cellView.backgroundColor = UIColor(red: 0.98, green: 0.7, blue: 0.1, alpha: 1)
                }
            })
            cell.dersinAdıLabel.text = dersinAdi[indexPath.row].uppercased(with:Locale(identifier: "tr"))
            cell.dersinOgrtLabel.text = dersinOgrt[indexPath.row].capitalized
            cell.okulBolumLabel.text = dersinOkulu[indexPath.row].capitalized + " & " + dersinBolumu[indexPath.row].capitalized
        }
        return cell
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if aramaBar.text == nil || aramaBar.text == "" {
            isarama = false
            view.endEditing(true)
            dersTablosu.reloadData()
        } else {
            
            arama = dersinAdi.filter({$0.lowercased() == aramaBar.text?.lowercased()})
            let indexarray = dersinAdi.indices.filter{dersinAdi[$0].localizedCaseInsensitiveContains(aramaBar.text!)}
            
            if let index = dersinAdi.index(of: aramaBar.text!.lowercased()){
                aramaSonucIndex = indexarray
                print(aramaSonucIndex)
                print(indexarray)
                print(index)
                isarama = true
                dersTablosu.reloadData()
            }
           
            if indexarray.isEmpty {
                 arama = dersinOgrt.filter({$0.lowercased() == aramaBar.text?.lowercased()})
                 let indexarray1 = dersinOgrt.indices.filter{dersinOgrt[$0].localizedCaseInsensitiveContains(aramaBar.text!.lowercased())}
                if let index = dersinOgrt.index(of: aramaBar.text!.lowercased()) {
                    print(indexarray)
                    print(index)
                    aramaSonucIndex = indexarray1
                    isarama2 = true
                    isarama = true
                    dersTablosu.reloadData()
                }
             }
           }
    }


}
