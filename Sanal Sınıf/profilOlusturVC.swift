//
//  profilOlusturVC.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 6.11.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import DLRadioButton

class profilOlusturVC: UIViewController {
    
    @IBOutlet weak var EMailText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
   
    
    @IBAction func ogretmenRadio(_ sender: DLRadioButton) {
        
        if sender.tag == 1 {
            print("Ogretmen")
        }else{
            print("ogrenci")
        }
    }
    
   

    @IBAction func geriDonClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func kaydetClicked(_ sender: Any) {
        
     /*   if emailText.text != "" && passwordText.text != "" {
            
            
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (User, Error) in
                
                if Error != nil{
                    
                    let alert = UIAlertController(title: "Hata", message: Error?.localizedDescription, preferredStyle: .alert)
                    let alButon = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(alButon)
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    
                    self.performSegue(withIdentifier: "toInformation", sender: nil)
                    
                    
                }
                
                
            })
            
            
            
        }else{
            
            
            let alert = UIAlertController(title: "HATA!", message: "E-mail ve ya şifre boş bırakılamaz.", preferredStyle: .alert)
            let alButon = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(alButon)
            self.present(alert, animated: true, completion: nil)
            
            
            
            
        }*/

        
        
        
    }
    
}
