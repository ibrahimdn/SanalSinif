//
//  odevKontrolVC.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 26.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MBProgressHUD
import Alamofire
import WebKit

@available(iOS 10.0, *)
class odevKontrolVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var postID = String()
    var dersID = String()
    var odevBilgisi = [odev]()
    var fileLocalURLDict = [Int:String]()
    
    @IBOutlet weak var odevTable: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        odevData()
        odevTable.tableFooterView = UIView()
        odevTable.delegate = self
        odevTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! odevKontrolCell
        cell.dosyAdiLabel.text = odevBilgisi[indexPath.row].dosyaAdi
        cell.ogrenciAdiLabel.text = odevBilgisi[indexPath.row].EkleyenKisiAd
        cell.delegate = self as? cellDelegate
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return odevBilgisi.count
    }
    
    func odevData (){
    
        Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("derslerim").child(dersID).child("post").child(postID).observe(.childAdded, with: { (DataSnapshot) in
            
            if let values = DataSnapshot.value as? NSDictionary {
               let valuesid = values.allKeys
                for id in valuesid {
                    if let value = values[id] as? NSDictionary {
                         let odevBilgi = odev(odevId: id as! String, odevData: values[id] as! [String : AnyObject])
                         self.odevBilgisi.insert(odevBilgi, at: 0)
                    }
                }
            }
        })
        self.odevTable.reloadData()
    }
    
    func didodevClicked(cell: UITableViewCell) {
        let indexPath = self.odevTable.indexPath(for: cell)
        print("Clicked0")
        if let index = indexPath?.row {
            /*let vc = self.storyboard?.instantiateViewController(withIdentifier: "toPdfGoruntuleVC") as! pdfGoruntuleVC
            
            let urlString:String! = fileLocalURLDict[(indexPath?.row)!]
            vc.url = urlString
            
            self.navigationController?.pushViewController(vc, animated: true)*/
            performSegue(withIdentifier: "toPdfGoruntuleyici2", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPdfGoruntuleyici2" {
            print("perfom Segue")
            let destination = segue.destination as! pdfGoruntuleVC
            destination.url = fileLocalURLDict[0]!
        }
    }
    
    func downloadFileWithIndex(ind:Int) {
        print("tıklandı")
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.annularDeterminate
        hud.label.text = "Yükleniyor..."
 
        let urlString = odevBilgisi[ind].pdfURL
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL:NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            let fileURL = documentsURL.appendingPathComponent(self.odevBilgisi[ind].dosyaAdi!)
            return (fileURL!,[.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(odevBilgisi[ind].pdfURL!, to: destination).downloadProgress(closure: { (prog) in
            hud.progress = Float(prog.fractionCompleted)
        }).response { response in
            hud.hide(animated: true)
            if response.error == nil, let filePath = response.destinationURL?.path {
                self.fileLocalURLDict[0] = filePath
                if  let urlString = self.fileLocalURLDict[0] {
                    self.performSegue(withIdentifier: "toPdfGoruntuleyici2", sender: nil)
                }
            }
        }
    }
}
