//
//  derslerimVC.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 22.12.2017.
//  Copyright © 2017 ibrahim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import Alamofire
import MBProgressHUD
import WebKit

@available(iOS 10.0, *)
class derslerimVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var derslerimSegment: UISegmentedControl!
    @IBOutlet weak var derslerimTable: UITableView!
    @IBOutlet weak var ogrencilerTable: UITableView!
   
    var postBilgisi = [Post]()
    var dersID = [String]()
    var pdfURL = String()
    var dosyaAdi = String()
    var fileLocalURLDict = [Int:String]()
    var index = Int()
    var odevEkleDersID = String ()
    var odevEkleÖğretmenID = String()
    var postID = String()
    var secilenDers = String()  // ders IDsi
    var secilenDersAdi = String()
    var secilenPostID = String()
    var kullaniciTipi = String()
    var p = Int()
    var kisiBilgi = [ogrenciBilgi]()
    var kisiBigi1 =  [String]()
   
    
    @IBOutlet weak var derslerimNavigationBar: UINavigationBar!
    @IBOutlet weak var duzenleClicked: UIBarButtonItem!
    
    @IBAction func geriClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentControlButton(_ sender: UISegmentedControl) {
        p = sender.selectedSegmentIndex
        print(p)
        if p == 0 {
            kullaniciData()
            ogrencilerTable.isHidden = true
            self.duzenleClicked.isEnabled = true
            derslerimTable.isHidden = false
        }
        if p == 1 {
            dersiAlanOgrenciler()
            derslerimTable.isHidden = true
            self.duzenleClicked.isEnabled = false
            ogrencilerTable.isHidden = false
        }
        
    }
    @IBOutlet weak var derslerim: UINavigationItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        kullaniciData()
        ogrencilerTable.dataSource = self
        ogrencilerTable.delegate = self
        ogrencilerTable.isEditing = false
        derslerimTable.tableFooterView = UIView()
        derslerimTable.delegate = self
        derslerimTable.dataSource = self
        self.derslerimTable.setEditing(isEditing, animated: true)
        derslerimTable.estimatedRowHeight = 130
        derslerimTable.accessibilityElementIsFocused()
        print(secilenDers)
        derslerim.title = secilenDersAdi
        self.title = secilenDers
      
    }
    
    func dersiAlanOgrenciler(){
         kisiBigi1.removeAll()
        Database.database().reference().child("kullanicilar").observe(.childAdded, with: { (DataSnapshot) in
           
            let values = DataSnapshot.value as! NSDictionary
            if let dersler = values["dersler"] as? NSDictionary {
                print(dersler)
                let dersIDler = dersler.allKeys
                for id in dersIDler {
                    if self.secilenDers == id as? String {
                        print(self.secilenDers)
                        print(values["kisiselBilgiler"]!)
                        if let bilgi = values["kisiselBilgiler"] as? NSDictionary {
                            print("ders ALAN öğrenci")
                            if bilgi["ad"] as! String != "" {
                                let ogrenciIsim: String = (bilgi["ad"] as! String) + " - " + (bilgi["okul"] as! String) + " / " + (bilgi["bolum"] as! String)
                            self.kisiBigi1.append(ogrenciIsim)
                            }
                        }
                    }
                }
                
            }
           self.ogrencilerTable.reloadData()
        print(self.kisiBigi1)
        })
       
    }

    func kullaniciData(){
        
        Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).observe(.childAdded, with: { (snapshot) in
            let kulVeri = snapshot.value! as! NSDictionary
            if "öğrenci" == kulVeri["gorevi"] as? String {
                self.kullaniciTipi = kulVeri["gorevi"] as! String
                self.duzenleClicked.title = "Dersi Sil"
                self.derslerimTable.isEditing = false
                self.duzenleClicked.isEnabled = true
                self.derslerimTable.isEditing = false
                self.derslerimSegment.isHidden = true
            }
            self.butunVeri()
        })
    }
    
    @IBAction func düzenleClicked(_ sender: UIBarButtonItem) {
        if kullaniciTipi == "öğrenci" {
            
            let alert = UIAlertController(title: "\(secilenDersAdi)", message: "", preferredStyle: .alert)
            let sil = UIAlertAction(title: "Sil", style: .destructive) { (UIAlertAction) in
                
                Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").child(self.secilenDers).removeValue()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPost"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            let iptal = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            alert.addAction(iptal)
            alert.addAction(sil)
            self.present(alert, animated: true, completion: nil)
            
        }else {
            self.derslerimTable.isEditing = !self.derslerimTable.isEditing
            self.derslerimTable.isUserInteractionEnabled = true
            sender.title = (self.derslerimTable.isEditing) ? "Tamam" : "Düzenle"
        }
        
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenPostID = postBilgisi[indexPath.row].postId
       
        if kullaniciTipi != "öğrenci" {
            if postBilgisi[indexPath.row].odev == true {
                performSegue(withIdentifier: "toOdevKontrolVC", sender: nil)
            }
            
        }
     
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toOdevKontrolVC" {
            let destination = segue.destination as! odevKontrolTableVC
            destination.dersID = secilenDers
            destination.postID = secilenPostID
        }
        if segue.identifier == "toPdfGoruntuleVC1" {
            let destination = segue.destination as! pdfGoruntuleVC
            destination.url = fileLocalURLDict[0]!
        }

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if kullaniciTipi != "öğrenci" {
            
            if editingStyle == .delete {
           
            _ = Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("derslerim").child(postBilgisi[indexPath.row].dersID).child("post").child(postBilgisi[indexPath.row].postId).removeValue(completionBlock: { (error, DatabaseReference) in
                if error != nil {
                }
                
            })
        }
            derslerimTable.setEditing(editingStyle != .delete, animated: true)
            derslerimTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let rowToMove = postBilgisi[fromIndexPath.row]
        postBilgisi.remove(at: fromIndexPath.row)
        postBilgisi.insert(rowToMove, at: toIndexPath.row)
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if p == 0 {
          return postBilgisi.count
        } else {
            return kisiBigi1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        postBilgisi.sort(by: { $0.tarih > $1.tarih })
        if p == 0 {
            if postBilgisi[indexPath.row].resimURL != "" {
                if postBilgisi[indexPath.row].aciklama != "" {
                    let cell = Bundle.main.loadNibNamed("duyuruCell3", owner: self, options: nil)?.first as! duyuruCell3
                    let pictureTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                    cell.duyuruResim.addGestureRecognizer(pictureTap)
                    cell.imageView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height*0.6)
                    cell.selectionStyle = .none
                    cell.delegate = self as? cell3delegate
                    if postBilgisi[indexPath.row].odev == true {
                        cell.starpng.isHidden = false
                        // cell.isUserInteractionEnabled = true
                    }else {
                        cell.starpng.isHidden = true
                        // cell.isUserInteractionEnabled = false
                    }
                    cell.ogretmenLabel.text = postBilgisi[indexPath.row].paylasanAdi + " & " + postBilgisi[indexPath.row].dersAdi
                    cell.selectionStyle = .none
                    cell.delegate = self as? cell3delegate
                    cell.aciklamaLabel.text = postBilgisi[indexPath.row].aciklama
                    cell.baslikLabel.text = postBilgisi[indexPath.row].baslik?.uppercased()
                    cell.tarihLabel.text = postBilgisi[indexPath.row].tarih
                    cell.duyuruResim.sd_setImage(with: URL(string: postBilgisi[indexPath.row].resimURL!))
                    if postBilgisi[indexPath.row].dosyaAdi != "Seçili Dosya Yok" {
                        cell.isUserInteractionEnabled = true
                        cell.dosyaAdButton.tag = indexPath.row
                        cell.dosyaAdButton.titleLabel?.textColor = UIColor.blue
                        if kullaniciTipi != "öğrenci" && postBilgisi[indexPath.row].odev == true{
                            cell.isSelected = true
                        }else {
                            cell.dosyaAdButton.isSelected = false
                        }
                        cell.dosyaAdButton.setTitle(postBilgisi[indexPath.row].dosyaAdi, for: .normal)
                        if postBilgisi[indexPath.row].pdfURL != "" {
                            cell.dosyaAdButton.addTarget(self, action: #selector(derslerimVC.pdfGoster), for: .touchUpInside)
                        }else {
                            cell.dosyaAdButton.addTarget(self, action: #selector(derslerimVC.zipGoster), for: .touchUpInside)
                        }
                    }else{
                        cell.dosyaAdButton.isHidden = true
                    }
                    return cell
                } else {
                    let cell = Bundle.main.loadNibNamed("duyuruCell2", owner: self, options: nil)?.first as! duyuruCell2
                    let pictureTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                    cell.duyuruResim.addGestureRecognizer(pictureTap)
                    cell.imageView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height*0.6)
                    cell.selectionStyle = .none
                    cell.delegate = self as? cell2delegate
                    if postBilgisi[indexPath.row].odev == true {
                        cell.starpng.isHidden = false
                        // cell.isUserInteractionEnabled = true
                    }else {
                        cell.starpng.isHidden = true
                        // cell.isUserInteractionEnabled = false
                    }
                    cell.ogretmenLabel.text = postBilgisi[indexPath.row].paylasanAdi + " & " + postBilgisi[indexPath.row].dersAdi
                    cell.selectionStyle = .none
                    cell.delegate = self as? cell2delegate
                    cell.baslikLabel.text = postBilgisi[indexPath.row].baslik?.uppercased()
                    cell.tarihLabel.text = postBilgisi[indexPath.row].tarih
                    cell.duyuruResim.sd_setImage(with: URL(string: postBilgisi[indexPath.row].resimURL!))
                    if postBilgisi[indexPath.row].dosyaAdi != "Seçili Dosya Yok"{
                        cell.isUserInteractionEnabled = true
                        cell.dosyaAdButton.tag = indexPath.row
                        if kullaniciTipi != "öğrenci" && postBilgisi[indexPath.row].odev == true {
                            cell.isSelected = true
                        }else {
                            cell.dosyaAdButton.isSelected = false
                        }
                        cell.dosyaAdButton.titleLabel?.textColor = UIColor.blue
                        cell.dosyaAdButton.setTitle(postBilgisi[indexPath.row].dosyaAdi, for: .normal)
                        if postBilgisi[indexPath.row].pdfURL != "" {
                            cell.dosyaAdButton.addTarget(self, action: #selector(derslerimVC.pdfGoster), for: .touchUpInside)
                        }else {
                            cell.dosyaAdButton.addTarget(self, action: #selector(derslerimVC.zipGoster), for: .touchUpInside)
                        }
                    }else{
                        cell.dosyaAdButton.isHidden = true
                    }
                    return cell
                }
            }else {
                let cell = Bundle.main.loadNibNamed("duyuruCell1", owner: self, options: nil)?.first as! duyuruCell1
                cell.selectionStyle = .none
                cell.delegate = self as? cell1delegate
                if postBilgisi[indexPath.row].odev == true {
                    cell.starpng.isHidden = false
                    // cell.isUserInteractionEnabled = true
                }else {
                    cell.starpng.isHidden = true
                    // cell.isUserInteractionEnabled = false
                }
                cell.ogretmenLabel.text = postBilgisi[indexPath.row].paylasanAdi + " & " + postBilgisi[indexPath.row].dersAdi
                cell.selectionStyle = .none
                cell.delegate = self as? cell1delegate
                cell.baslikLabel.text = postBilgisi[indexPath.row].baslik?.uppercased()
                cell.tarihLabel.text = postBilgisi[indexPath.row].tarih
                cell.aciklamaLabel.text = postBilgisi[indexPath.row].aciklama
            
                if postBilgisi[indexPath.row].dosyaAdi != "Seçili Dosya Yok"  {
                    cell.isUserInteractionEnabled = true
                    cell.dosyaAdButton.tag = indexPath.row
                    cell.dosyaAdButton.titleLabel?.textColor = UIColor.blue
                    cell.dosyaAdButton.setTitle(postBilgisi[indexPath.row].dosyaAdi!, for: .normal)
                    if kullaniciTipi != "öğrenci" && postBilgisi[indexPath.row].odev == true {
                        cell.isSelected = true
                    }else {
                    cell.dosyaAdButton.isSelected = false
                        }
                    if postBilgisi[indexPath.row].pdfURL != "" {
                    cell.dosyaAdButton.addTarget(self, action: #selector(derslerimVC.pdfGoster), for: .touchUpInside)
                    }else {
                        cell.dosyaAdButton.addTarget(self, action: #selector(derslerimVC.zipGoster), for: .touchUpInside)
                    }
                }else{
                    cell.dosyaAdButton.isHidden = true
                }
                return cell
            }
        }else {
         
            let cell = Bundle.main.loadNibNamed("ogrenciKontrolCell", owner: self, options: nil)?.first as! ogrenciKontrolCell
        
            cell.isSelected = false
            cell.isEditing = false
            cell.selectionStyle = .none
            cell.isimLabel.text =  String(indexPath.row + 1) + ") " + kisiBigi1[indexPath.row]
            return cell
        }
    }
    
    func zipGoster(sender: UIButton ){
        let touchPoint = sender.convert(CGPoint.zero, to: self.derslerimTable)
        var clickedButtonIndexPath = derslerimTable.indexPathForRow(at: touchPoint)
        NSLog("index path.section ==%ld", Int((clickedButtonIndexPath?.section)!))
        NSLog("index path.row ==%ld", Int((clickedButtonIndexPath?.row)!))
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.annularDeterminate
        hud.label.text = "Yükleniyor..."
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL:NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            let fileURL = documentsURL.appendingPathComponent(self.postBilgisi[(clickedButtonIndexPath?.row)!].dosyaAdi!)
            return (fileURL!,[.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(postBilgisi[(clickedButtonIndexPath?.row)!].zipURL!, to: destination).downloadProgress(closure: { (prog) in
            hud.progress = Float(prog.fractionCompleted)
        }).response { response in
            hud.hide(animated: true)
            if response.error == nil, let filePath = response.destinationURL?.path {
                self.fileLocalURLDict[0] = filePath
                let alert = UIAlertController(title: "", message: "Dosya indirildi.", preferredStyle: .alert)
                let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
                alert.addAction(alertButon)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pdfGoster (sender: UIButton){
        
        let touchPoint = sender.convert(CGPoint.zero, to: self.derslerimTable)
        var clickedButtonIndexPath = derslerimTable.indexPathForRow(at: touchPoint)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.annularDeterminate
        hud.label.text = "Yükleniyor..."
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL:NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            let fileURL = documentsURL.appendingPathComponent(self.postBilgisi[(clickedButtonIndexPath?.row)!].dosyaAdi!)
            return (fileURL!,[.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(postBilgisi[(clickedButtonIndexPath?.row)!].pdfURL!, to: destination).downloadProgress(closure: { (prog) in
            hud.progress = Float(prog.fractionCompleted)
        }).response { response in
            hud.hide(animated: true)
            if response.error == nil, let filePath = response.destinationURL?.path {
                self.fileLocalURLDict[0] = filePath
                if  let urlString = self.fileLocalURLDict[0] {
                    self.performSegue(withIdentifier: "toPdfGoruntuleVC1", sender: nil)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func butunVeri(){
      
        if kullaniciTipi == "öğrenci"
        {
            Database.database().reference().child("kullanicilar").observe(.childAdded, with: { (DataSnapshot) in
                if let kullanicilar = DataSnapshot.value as? NSDictionary {
                    if let dersBilgileri = kullanicilar["derslerim"] as? NSDictionary {
                        let dersIDleri = dersBilgileri.allKeys
                        for id in dersIDleri {
                            if id as? String == self.secilenDers {
                                if let postlarBilgisi = dersBilgileri[id] as? NSDictionary {
                                    if let postlar = postlarBilgisi["post"] as? NSDictionary{
                                        let postidler = postlar.allKeys
                                        for postid in postidler {
                                            if let post = postlar[postid] as? NSDictionary {
                                                print(post)
                                                let post1 = Post(postID: id as! String, postData: post["postBilgisi"] as! [String : AnyObject])
                                                self.postBilgisi.insert(post1, at: 0)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
               self.derslerimTable.reloadData()
            })
        }else {
            Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).queryOrdered(byChild: "Tarih").observe( .value, with: { (DataSnapshot) in
                self.postBilgisi.removeAll()
                let values = DataSnapshot.value as! NSDictionary
                    if let derslerim = values["derslerim"] as? NSDictionary {
                        let derslerId = derslerim.allKeys
                        for dersId in derslerId {
                            if dersId as! String == self.secilenDers {
                                let ders = derslerim[dersId] as! NSDictionary
                                if let postlar = ders["post"] as? NSDictionary {
                                    let postlarId = postlar.allKeys
                                    for postId in postlarId {
                                        if let post = postlar[postId] as? NSDictionary{
                                            let post1 = Post(postID: postId as! String, postData: post["postBilgisi"] as! [String : AnyObject])
                                            self.postBilgisi.insert(post1, at: 0)
                                        }
                                    }
                                }
                            }
                        }
                    }
                self.derslerimTable.reloadData()
            })
        }
    }
}
