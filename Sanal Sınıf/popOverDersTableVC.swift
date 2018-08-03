//
//  popOverDersTable.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 22.12.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@available(iOS 10.0, *)
class popOverDersTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var popViewTable: UIView!
    @IBOutlet weak var table: UITableView!
    var ogretmenId = [String]()
    var dosyaURL = [NSURL]()
    var secilenDosyaAdi = String()
    var secilenDosyaURL = NSURL()
    var secilenOgretmenId = String()
    var dosyaIsimleri = [String]()
    var dersinAdi = [String]()
    var secilenDersAdi = String()
    var dersID = [String]()
    var currentUserID : String = (Auth.auth().currentUser?.uid)!
    var tableGosterimi = Int ()
    var secim = Int()
    var duyuruSecimi = Int ()
    var secilenDersID = String()
    var secilenDersOgretmeni = String()
    var postID = String()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        table.tableFooterView = UIView()
        tabloVeriSecimi()
        table.dataSource = self
        table.delegate = self
        popViewTable.layer.cornerRadius = 10
        popViewTable.layer.masksToBounds = true
        
    }
    
    func tabloVeriSecimi(){
        
        print("Tablo Secimi \(tableGosterimi)")
        if tableGosterimi == 1 {
            kullaniciDersleri()
            print("Tablo Secimi \(tableGosterimi)")
        }
        else if tableGosterimi == 2 || tableGosterimi == 3 || tableGosterimi == 6{
            kullaniciDerslerim()
            print("Tablo Secimi \(tableGosterimi)")
        }
        else if tableGosterimi == 4 {
            pdfSec()
            print("Tablo Secimi \(tableGosterimi)")
        }
        else if tableGosterimi == 5 {
            pdfSec()
            print("Tablo Secimi \(tableGosterimi)")
        }
        else if tableGosterimi == 7 {
            kullaniciDersleri()
        }
    }
    
    func pdfSec(){
       
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            for item in directoryContents {
                print("item = \(item)")
                if item.path.hasSuffix("zip") || item.path.hasSuffix("pdf") {
                    print("path : \(item.path)")
                    let pdfFiles = directoryContents.filter{ $0.pathExtension == "zip" || $0.pathExtension == "pdf" }
                    let pdfFileNames = pdfFiles.map{ $0.lastPathComponent }
                    dosyaIsimleri = pdfFileNames
                    dersinAdi = pdfFileNames
                    dosyaURL.append(item as NSURL)
                }
            }
            print("Dosya isimleri\(dosyaIsimleri) \n dosya sayısı \(dosyaIsimleri.count) dersin Adi:\(dersinAdi)")
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func kullaniciDerslerim(){
       
        Database.database().reference().child("kullanicilar").child(currentUserID).observe(.value, with: { (DataSnapshot) in
            let values = DataSnapshot.value as! NSDictionary
            if values["derslerim"] != nil{
                let value = values["derslerim"] as! NSDictionary
                let dersIDs = value.allKeys
                for id in dersIDs {
                    let singleDers = value[id] as! NSDictionary
                    self.dersID.append(id as! String)
                    if let dersBilgi = singleDers["dersBilgisi"] as? NSDictionary {
                        self.dersinAdi.append((dersBilgi["adi"] as! String).capitalized)
                    }
                }
            }else {
                self.view.makeToast("Ders Bulunamadı.")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func kullaniciDersleri(){
        
        Database.database().reference().child("kullanicilar").child(currentUserID).observe(.value, with: { (DataSnapshot) in
            let values = DataSnapshot.value as! NSDictionary
            if values["dersler"] != nil{
                let value = values["dersler"] as! NSDictionary
                let dersIDs = value.allKeys
                for id in dersIDs {
                    let singleDers = value[id] as! NSDictionary
                    self.dersID.append(id as! String)
                    let dersBilgi = singleDers["dersBilgisi"] as! NSDictionary
                    self.dersinAdi.append((dersBilgi["Adi"] as! String).capitalized)
                    self.ogretmenId.append((dersBilgi["ogretmenId"] as! String))
                }
            }else {
                self.view.makeToast("Ders Bulunamadı.")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dersinAdi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            print(dersinAdi)
            cell.textLabel?.text = dersinAdi[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableGosterimi == 3 { // duyuru ekleme
            secilenDersID = dersID[indexPath.row]
            secilenDersAdi = dersinAdi[indexPath.row]
            print(secilenDersID)
            performSegue(withIdentifier: "toDuyuruEkleVC", sender: nil)
            
        }
        else if tableGosterimi == 2{ // derslerim
           secilenDersID = dersID[indexPath.row]
           secilenDersAdi = dersinAdi[indexPath.row]
           performSegue(withIdentifier: "toDerslerimVC", sender: nil)
        }
        else if tableGosterimi == 4{    // dosya ekleme
            secilenDosyaAdi = dosyaIsimleri[indexPath.row]
            secilenDosyaURL = dosyaURL[indexPath.row]
            performSegue(withIdentifier: "toDuyuruEkleVC2", sender: nil)
        }
        else if tableGosterimi == 5{    // odev ekleme
            secilenDosyaAdi = dosyaIsimleri[indexPath.row]
            secilenDosyaURL = dosyaURL[indexPath.row]
            performSegue(withIdentifier: "toOdevEkleVC", sender: nil)
        }
        else if tableGosterimi == 1 {
            secilenDersID = dersID[indexPath.row]
            secilenDersAdi = dersinAdi[indexPath.row]
            performSegue(withIdentifier: "toDerslerVC", sender: nil)
        }
        else if tableGosterimi == 6 {
            secilenDersID = dersID[indexPath.row]
            secilenDersAdi = dersinAdi[indexPath.row]
            let alert = UIAlertController(title: "\(secilenDersAdi)", message: "", preferredStyle: .alert)
          
            let sil = UIAlertAction(title: "Sil", style: .destructive) { (UIAlertAction) in
                
                    Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("derslerim").child(self.secilenDersID).removeValue()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPost"), object: nil)
                self.dismiss(animated: true, completion: nil)
                }
            
            let iptal = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            alert.addAction(iptal)
            alert.addAction(sil)
            self.present(alert, animated: true, completion: nil)
            
        }
        else if tableGosterimi == 7 {
            secilenDersID = dersID[indexPath.row]
            secilenDersAdi = dersinAdi[indexPath.row]
            secilenOgretmenId = ogretmenId[indexPath.row]
            performSegue(withIdentifier: "toGruplarVC", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDerslerimVC" {
            let destination = segue.destination as! derslerimVC
            destination.secilenDers = secilenDersID
            destination.secilenDersAdi = secilenDersAdi
        }
        if segue.identifier == "toDuyuruEkleVC" {
            let destinationEkle = segue.destination as! duyuruEkleVC
            destinationEkle.dersAdi = secilenDersAdi
            destinationEkle.duyuruSecilenDers = secilenDersID
        }
       if segue.identifier == "toDuyuruEkleVC2" {
            let destinationEkle = segue.destination as! duyuruEkleVC
            destinationEkle.dosyaAdi = secilenDosyaAdi
            destinationEkle.dosyaURL = secilenDosyaURL
        }
        if segue.identifier == "toOdevEkleVC" {
            let destination = segue.destination as! odevEkleVC
            destination.dosyaAdi = secilenDosyaAdi
            destination.dosyaURL = secilenDosyaURL
        }
        if segue.identifier == "toDerslerVC" {
            let destination = segue.destination as! derslerimVC
            destination.secilenDersAdi = secilenDersAdi
            destination.secilenDers = secilenDersID
        }
        if segue.identifier == "toGruplarVC" {
            let destination = segue.destination as! gruplarVC
            destination.ogretmenID = secilenOgretmenId
            destination.dersId = secilenDersID
            destination.dersAdi = secilenDersAdi
        }
    }
    
    @IBAction func iptalClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



















