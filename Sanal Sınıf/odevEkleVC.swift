//
//  odevEkleVC.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 12.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import MBProgressHUD

@available(iOS 10.0, *)
class odevEkleVC: UIViewController {

    let defaults = UserDefaults.standard
    var dersID = String()
    var dosyaAdi = String()
    var dosyaURL = NSURL()
    var odevURL = String()
    var dersinOgretmeni = String ()
    var postID = String()
    var kullaniciAdi = String()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func OdevEkleClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dosyaEkleClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "toDosyaEklePop", sender: nil)
    }
   
    @IBAction func dosyaYukleClicked(_ sender: Any) {
        
        let uuid = NSUUID(uuidString: dersID)
        var butunData = ["PdfURL" : "" ,"ZipURL": "", "Tarih" : getTarih(), "EkleyenKisiAd" : kullaniciAdi ,"ekleyenKisiID": (Auth.auth().currentUser?.uid)!,"DosyaAdi" :dosyaAdLabel.text!] as [String: Any]
            if dosyaURL.isFileURL {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = MBProgressHUDMode.annularDeterminate
                hud.label.text = "Ödev Yükleniyor ..."
                
                let dataRef = Database.database().reference().child("kullanicilar").child(defaults.object(forKey: "dersinOgretmeni") as! String).child("derslerim").child(defaults.object(forKey: "dersID") as! String).child("post").child(defaults.object(forKey: "postID") as! String).child("Odevler").childByAutoId()
                
                let doc = UIDocument(fileURL: self.dosyaURL as URL)
                let pdfDosyasi = Storage.storage().reference().child("pdf").child("\(String(describing: uuid))").putFile(from: doc.fileURL as URL , metadata: nil) { metadata, error in
                    
                    if (error != nil) {
                        let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        self.odevURL = (metadata!.downloadURL()?.absoluteString)!
                        print("pdfURL \(self.odevURL)")
                        butunData["PdfURL"] = self.odevURL
                        dataRef.setValue(butunData)
                    }
                }
                pdfDosyasi.observe(.progress, handler: { (snapshot) in
                    guard let progress = snapshot.progress else {return}
                    hud.progress = Float(progress.fractionCompleted)
                })
                pdfDosyasi.observe(.success, handler: { (snapshot) in
                    hud.hide(animated: true)
                })
            } else {
                let alert = UIAlertController(title: "Hata!", message: "Ödev Seçilmedi", preferredStyle: .alert)
                let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                alert.addAction(alertButon)
                self.present(alert, animated: true, completion: nil)
            }
                
        resetDefaults()
                
    }
    func gelenData(){
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("kullanicilar").child(uid!).observe(.childAdded, with: { (snapshot) in
            let values = snapshot.value as! NSDictionary
            let keys = values.allKeys
            for key in keys {
                if key as! String == "ad" {
                   print(values[key]!)
                    self.kullaniciAdi = values[key] as! String
                }
            }
            
        })
      //  setUserDefaults()
    }
    
        
    func getTarih() -> String {
        let vc : duyuruEkleVC = duyuruEkleVC(nibName: nil, bundle: nil)
        return vc.tarih()
    }
    
    @IBOutlet weak var dosyaAdLabel: UILabel!
    
    func setUserDefaults(){
        defaults.set(postID, forKey: "postID")
        defaults.set(dersID, forKey: "dersID")
        defaults.set(dersinOgretmeni, forKey: "dersinOgretmeni")
        defaults.set(kullaniciAdi, forKey: "kullaniciAdi")
    }
    func getUserDefaults(){
        if defaults.object(forKey: "postID") != nil {
            postID = (defaults.object(forKey: "postID") as? String)!
        }
        if defaults.object(forKey: "dersID") != nil {
            dersID = defaults.object(forKey: "dersID") as! String
        }
        if defaults.object(forKey: "dersinOgretmeni") != nil {
            dersinOgretmeni = defaults.object(forKey: "dersinOgretmeni") as! String
        }
        if defaults.object(forKey: "kullaniciAdi") != nil {
            kullaniciAdi = defaults.object(forKey: "kullaniciAdi") as! String
        }
        
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    override func viewDidLoad() {
        
        gelenData()
        if dosyaAdi != "" {
            dosyaAdLabel.text = dosyaAdi
        }
        if dersinOgretmeni.isEmpty {
            dersinOgretmeni = defaults.object(forKey: "dersinOgretmeni") as! String
        }else{
            defaults.set(dersinOgretmeni, forKey: "dersinOgretmeni")
        }
        if postID.isEmpty {
            postID = defaults.object(forKey: "postID") as! String
        }else{
            defaults.set(postID, forKey: "postID")
        }
        if dersID.isEmpty {
            dersID = defaults.object(forKey: "dersID") as! String
        }else{
            defaults.set(dersID, forKey: "dersID")
        }
        if kullaniciAdi.isEmpty {
            if defaults.object(forKey: "kullaniciAdi") != nil {
                kullaniciAdi = defaults.object(forKey: "kullaniciAdi") as! String
            }
        }else {
            defaults.set(kullaniciAdi, forKey: "kullaniciAdi")
        }
        super.viewDidLoad()
       // self.navigationController?.isNavigationBarHidden = false
    }
    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destController : popOverDersTableVC = segue.destination as! popOverDersTableVC
        destController.tableGosterimi = 5
       
    }
   
}
