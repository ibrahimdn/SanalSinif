//
//  new.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 7.11.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import DLRadioButton
import Firebase
import FirebaseAuth
import FirebaseDatabase

@available(iOS 10.0, *)
class profilOlusVC: UIViewController {
   
    @IBOutlet weak var adText: UITextField!
    @IBOutlet weak var okulText: UITextField!
    @IBOutlet weak var bolumText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var sifreText: UITextField!
    
    var gorevi = String()
    var uuid = NSUUID().uuidString
    
    override func viewDidLoad() {
    
        sifreText.isSecureTextEntry = true
        emailText.keyboardType = .emailAddress
        super.viewDidLoad()
    }
    @IBAction func Kayıt(_ sender: UIButton) {
        
        if  adText.text != "" &&
            okulText.text != "" &&
            bolumText.text != "" &&
            emailText.text != "" &&
            sifreText.text != ""   {
            
            Auth.auth().createUser(withEmail: emailText.text!, password: sifreText.text!, completion: { (User, Error) in
                
                if Error != nil {
                    
                    let alert = UIAlertController(title: "Hata!", message: Error?.localizedDescription , preferredStyle: .actionSheet)
                    let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                    alert.addAction(alertButon)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    UserDefaults.standard.set(User?.email!, forKey: "kullanici")
                    UserDefaults.standard.synchronize()
                    self.kisiselBilgiKaydet()
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.kullanicihatirlama()
                }
            })
        }else {
            
            let alert = UIAlertController(title: "Hata!", message: "Boş bırakılan alanaları doldurunuz.", preferredStyle: .alert)
            let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
            alert.addAction(alertButon)
            self.present(alert, animated: true, completion: nil)
        }
    }
   
    @IBAction func exitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
      
    func kisiselBilgiKaydet(){
        let user = Auth.auth().currentUser
        let kisiselBilgiler = [ "ad" : self.adText.text!,
                                "gorevi" : self.gorevi,
                                "okul" : self.okulText.text!,
                                "bolum" : self.bolumText.text!,
                                "email" : self.emailText.text!,
                                "sifre" : self.sifreText.text!,
                                "ppURL" : "Bos",
                                "uuid" : self.uuid] as [String : Any]
    
        Database.database().reference().child("kullanicilar").child((user?.uid)!).child("kisiselBilgiler").setValue(kisiselBilgiler)
    }
    
    @IBAction func ogretmenRadio(_ sender: DLRadioButton) {
        
        if sender.tag == 1 {
            gorevi = "öğretmen"
        }else{
            gorevi = "öğrenci"
        }
    }

}
