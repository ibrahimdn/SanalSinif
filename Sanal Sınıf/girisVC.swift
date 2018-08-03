//
//  girisVC.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 5.11.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@available(iOS 10.0, *)
class girisVC: UIViewController {
 
    @IBOutlet var kayit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.isSecureTextEntry=true
        emailText.keyboardType = .emailAddress
   
    }
  
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBAction func kayitClicked(_ sender: Any) {
        performSegue(withIdentifier: "toprofilOlus", sender: nil)
    }
    
    @IBAction func girisClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != "" {
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (User, Error) in
                
                if Error != nil {
                    let alert = UIAlertController(title: "Hata!", message: Error?.localizedDescription, preferredStyle: .alert)
                    let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                    alert.addAction(alertButon)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    UserDefaults.standard.set(User!.email, forKey: "kullanici")
                    UserDefaults.standard.synchronize()
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.kullanicihatirlama()
                }
            })
            
        }else{
           
            let alert = UIAlertController(title: "Hata!", message: "Email veya şifre boş bırakılamaz", preferredStyle: .alert)
            let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
            alert.addAction(alertButon)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
