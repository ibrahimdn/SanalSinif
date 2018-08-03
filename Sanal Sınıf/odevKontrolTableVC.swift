//
//  odevKontrolTableVC.swift
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
class odevKontrolTableVC: UITableViewController,cellDelegate {

    var postID = String()
    var dersID = String()
    var odevBilgisi = [odev]()
    var fileLocalURLDict = [Int:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        odevData()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
      
    }
    
    @IBAction func odevlerTableClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)        
    }
    func didodevClicked(cell: UITableViewCell) {
        let index = self.tableView.indexPath(for: cell)
        print((index?.row)!)
        
        if let index = index?.row {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = MBProgressHUDMode.annularDeterminate
            hud.label.text = "Yükleniyor..."
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL:NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
                let fileURL = documentsURL.appendingPathComponent(self.odevBilgisi[index].dosyaAdi!)
                return (fileURL!,[.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(odevBilgisi[index].pdfURL!, to: destination).downloadProgress(closure: { (prog) in
                hud.progress = Float(prog.fractionCompleted)
            }).response { response in
                hud.hide(animated: true)
                if response.error == nil, let filePath = response.destinationURL?.path {
                    self.fileLocalURLDict[0] = filePath
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "toPdfGoruntuleVC") as! pdfGoruntuleVC
                    if  let urlString = self.fileLocalURLDict[0] {
                        vc.url = urlString
                        self.navigationController?.pushViewController(vc, animated: false)
                        self.performSegue(withIdentifier: "toPdfGoruntuleyici2", sender: nil)
                    }
                }
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return odevBilgisi.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! odevKontrolCell
        cell.dosyAdiLabel.text = odevBilgisi[indexPath.row].dosyaAdi
        cell.ogrenciAdiLabel.text = odevBilgisi[indexPath.row].EkleyenKisiAd
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
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
        self.tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if segue.identifier == "toPdfGoruntuleyici2" {
                let destination = segue.destination as! pdfGoruntuleVC
                destination.url = fileLocalURLDict[0]!
        }

    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
