//
//  SecondViewController.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 5.11.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

@available(iOS 10.0, *)
class profilVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   let picker = UIImagePickerController()
    var tabloSecimi : Int = 0
    var duyuruEkle : Int = 0
    var gecici = String ()
    var resimURL : String = ""
    
    @IBOutlet weak var gruplarClicked: UIButton!
    @IBOutlet weak var dersSilClicked: UIButton!
    @IBOutlet weak var ppResim: UIImageView!
    @IBOutlet weak var duyuruEkleClicked: UIButton!
    @IBOutlet weak var derslerClicked: UIButton!
    @IBOutlet weak var kaydetClicked: UIButton!
    @IBOutlet weak var dersAcClicked: UIButton!
    @IBOutlet weak var derslerimClicked: UIButton!
    @IBOutlet weak var adText: UITextField!
    @IBOutlet weak var okulText: UITextField!
    @IBOutlet weak var bolumText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var goreviText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        gelenData()
        let resimKaydet = UITapGestureRecognizer(target: self, action: #selector(profilVC.fotoSec))
        ppResim.addGestureRecognizer(resimKaydet)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fotoSec (){
        
        let Alert = UIAlertController(title: "Resim Seç", message: "",preferredStyle: .actionSheet)
        let camButton = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            self.camButton()
        }
        let galeriButton = UIAlertAction(title: "Galeri", style: .default) { (UIAlertAction) in
            self.galeriButton()
        }
        let iptalButton = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        Alert.addAction(camButton)
        Alert.addAction(galeriButton)
        Alert.addAction(iptalButton)
        self.present(Alert, animated: true, completion: nil)
    }
    func camButton(){
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
           
        }else{
            let alert = UIAlertController(title: "", message: "Kamera bulunamadı", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
    func galeriButton(){
      
        picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        ppResim.image = info[UIImagePickerControllerEditedImage] as? UIImage
               self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func gelenData(){
        let uid = Auth.auth().currentUser?.uid
  
        Database.database().reference().child("kullanicilar").child(uid!).observe(.childAdded, with: { (snapshot) in
            let kulVeri = snapshot.value! as! NSDictionary
            self.adText.text =  kulVeri["ad"] as? String
            self.okulText.text = kulVeri["okul"] as? String
            self.bolumText.text = kulVeri["bolum"] as? String
            self.emailText.text = kulVeri["email"] as? String
            self.goreviText.text = kulVeri["gorevi"] as? String
            let deger = kulVeri["ppURL"] as? String
            //print(deger)
            if  kulVeri["sifre"] != nil {
                self.gecici = kulVeri["sifre"] as! String
            }
            if "öğretmen" == kulVeri["gorevi"] as? String{
                    self.derslerimClicked.isHidden = false
                    self.dersAcClicked.isHidden = false
                    self.dersSilClicked.isHidden = false
                    self.duyuruEkleClicked.isHidden = false
            }
            if kulVeri["ppURL"] != nil {
                if kulVeri["ppURL"] as? String != "" {
                     self.ppResim.sd_setImage(with: URL(string: kulVeri["ppURL"] as! String))
                }else {
                    self.ppResim.image = #imageLiteral(resourceName: "profilresmi.png")
                }
               
            }
          })
    }
    
    @IBAction func düzenlelClicked(_ sender: UIButton) {
        ppResim.isUserInteractionEnabled = true
        adText.isUserInteractionEnabled = true
        okulText.isUserInteractionEnabled = true
        bolumText.isUserInteractionEnabled = true
        emailText.isUserInteractionEnabled = true
        goreviText.isUserInteractionEnabled = true
        kaydetClicked.isHidden=false
    }
    
    @IBAction func kaydetClicked(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        let uuid = NSUUID().uuidString
        var kisiselBilgiler = [ "ad" : self.adText.text!,
                                "gorevi" : self.goreviText.text!,
                                "okul" : self.okulText.text!,
                                "bolum" : self.bolumText.text!,
                                "email" : self.emailText.text!,
                                "ppURL" : resimURL,
                                "sifre" : gecici,
                                "uuid" : user!.uid] as [String : Any]
        
        if let data = UIImageJPEGRepresentation(ppResim.image!, 1){
        let mediaResim = Storage.storage().reference().child("resim").child("\(String(describing: uuid)).jpg").putData(data, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                kisiselBilgiler["ppURL"] = (metadata?.downloadURL()?.absoluteString)!
                print(self.resimURL)
                 Database.database().reference().child("kullanicilar").child((user?.uid)!).child("kisiselBilgiler").setValue(kisiselBilgiler)
            }
        })
       }
        adText.tintColor = .clear
        okulText.tintColor = .clear
        bolumText.tintColor = .clear
        goreviText.tintColor = .clear
        ppResim.isUserInteractionEnabled = false
        kaydetClicked.isHidden = true
    }
    
    @IBAction func dersSilClicked(_ sender: Any) {
        tabloSecimi = dersSilClicked.tag
        performSegue(withIdentifier: "toDerslerimPop", sender: nil)
        
    }
    @IBAction func dersAcClicked(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Yeni Ders ", message: "", preferredStyle: .alert)
        
        _=alert.addTextField { (UITextField) in
            
            UITextField.placeholder = "Dersin Adı"
        }
        _=alert.addTextField { (UITextField) in
            UITextField.placeholder = "Dersin Şifresi"
        }
        _=alert.addTextField { (UITextField) in
            UITextField.placeholder = "Üniversite"
        }
        _=alert.addTextField { (UITextField) in
            UITextField.placeholder = "Bölümü"
        }
        
        let adi = alert.textFields?[0]
        let sifre = alert.textFields?[1]
        let okulu = alert.textFields?[2]
        let bolumu = alert.textFields?[3]
        let alertEkle = UIAlertAction(title: "Ekle", style: .default) { (UIAlertAction) in
            
            if (alert.textFields?.isEmpty)!  {
                alert.message="Boş yerleri doldurunuz"
            }else {
                let dersBilgi = ["adi" :  adi?.text!.capitalized.lowercased(),
                                 "sifre" :  sifre?.text!,
                                 "okulu" : okulu?.text!.capitalized,
                                 "Bolumu" :  bolumu?.text!.capitalized,
                                 "ögretmen" : self.adText.text?.capitalized.lowercased(),
                                 "ogretmenId": Auth.auth().currentUser?.uid ]
                Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("derslerim").childByAutoId().child("dersBilgisi" ).setValue(dersBilgi)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPost"), object: nil)
            }
        }
        let alertCikis = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        alert.addAction(alertCikis)
        alert.addAction(alertEkle)
        self.present(alert, animated: true, completion: nil)
 
    }
   
    @IBAction func gruplarClicked(_ sender: Any) {
        tabloSecimi = gruplarClicked.tag
        performSegue(withIdentifier: "toDerslerimPop", sender: nil)
    }
   
    @IBAction func derslerimClicked(_ sender: UIButton) {
        print("derslerim \(derslerimClicked.tag)")
        tabloSecimi = derslerimClicked.tag
        performSegue(withIdentifier: "toDerslerimPop", sender: nil)
    }
    @IBAction func derslerClicked(_ sender: UIButton) {
        print("dersler \(derslerClicked.tag)")
        tabloSecimi = derslerClicked.tag
        performSegue(withIdentifier: "toDerslerPop", sender: nil)
    }
    @IBAction func duyuruEkleClicked(_ sender: UIButton) {
        print("duyuru Ekle \(duyuruEkleClicked.tag)")
        tabloSecimi = duyuruEkleClicked.tag
        performSegue(withIdentifier: "toDuyuruPop", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destController : popOverDersTableVC = segue.destination as! popOverDersTableVC
        print("ders secimi \(tabloSecimi)")
        destController.tableGosterimi = tabloSecimi
    }


}

