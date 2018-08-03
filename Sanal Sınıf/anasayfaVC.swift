//
//  FirstViewController.swift
//  Sanal Sınıf
//
//  Created by ibrahim on 5.11.2017.
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
class anasayfaVC: UIViewController ,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var duyuruTable: UITableView!
    
    var postBilgisi = [Post]()
    var dersID = [String]()
    var pdfURL = String()
    var dosyaAdi = String()
    var fileLocalURLDict = [Int:String]()
    var index = Int()
    var odevEkleDersID = String ()
    var odevEkleÖğretmenID = String()
    var postID = String()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postBilgisi.removeAll()
        dersIDs()
        //duyuruTable.isEditing = false
        duyuruTable.tableFooterView = UIView()
        duyuruTable.delegate = self
        duyuruTable.dataSource = self
        duyuruTable.rowHeight = UITableViewAutomaticDimension
        duyuruTable.allowsSelection = false
        duyuruTable.estimatedRowHeight = 25
        duyuruTable.accessibilityElementIsFocused()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(anasayfaVC.dersIDs), for: UIControlEvents.valueChanged)
        duyuruTable.addSubview(refreshControl)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(anasayfaVC.dersIDs), name: NSNotification.Name(rawValue: "dersEkleme"), object: nil)
     
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
 
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var  kaydet: UITableViewRowAction?
        self.postBilgisi.sort(by: { $0.tarih > $1.tarih })

        let nowTime:Double = NSDate().timeIntervalSince1970
        
        if self.postBilgisi[indexPath.row].odev == true   {
            if postBilgisi[indexPath.row].odevTarihi != nil {
                _ = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
                let result = formatter.date(from: (postBilgisi[indexPath.row].odevTarihi)!)
                if (result?.timeIntervalSince1970)! > nowTime {
               
                    kaydet = UITableViewRowAction(style: .default, title: "Ödev Ekle") { (action, index) in
                        self.odevEkleDersID = self.postBilgisi[indexPath.row].dersID
                        self.odevEkleÖğretmenID = self.postBilgisi[indexPath.row].paylasan!
                        self.postID = self.postBilgisi[indexPath.row].postId
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "odevEkleVC") as! odevEkleVC
                        vc.dersinOgretmeni = self.odevEkleÖğretmenID
                        vc.dersID = self.odevEkleDersID
                        vc.postID = self.postID
                        self.navigationController?.pushViewController(vc, animated: true)
                        }
                }else {
                    kaydet = UITableViewRowAction(style: .normal, title: "Ödevin süresi bitti.", handler: { (
                        action, IndexPath) in})
                }
            }else {
                kaydet = UITableViewRowAction(style: .default, title: "Ödev1 Ekle") { (action, index) in
                    self.odevEkleDersID = self.postBilgisi[indexPath.row].dersID
                    self.odevEkleÖğretmenID = self.postBilgisi[indexPath.row].paylasan!
                    self.postID = self.postBilgisi[indexPath.row].postId
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "odevEkleVC") as! odevEkleVC
                    vc.dersinOgretmeni = self.odevEkleÖğretmenID
                    vc.dersID = self.odevEkleDersID
                    vc.postID = self.postID
                    self.navigationController?.pushViewController(vc, animated: true)
                    }
            }
        }else {
            kaydet = UITableViewRowAction(style: .normal, title: "Ödev Yok", handler: { (
                action, IndexPath) in})
        }
         return [kaydet!]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return postBilgisi.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        postBilgisi.sort(by: { $0.tarih > $1.tarih })
      
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
                cell.aciklamaLabel.text = postBilgisi[indexPath.row].aciklama
                cell.baslikLabel.text = postBilgisi[indexPath.row].baslik?.uppercased()
                cell.tarihLabel.text = postBilgisi[indexPath.row].tarih
                cell.ogretmenLabel.text = postBilgisi[indexPath.row].paylasanAdi + " & " + postBilgisi[indexPath.row].dersAdi
                cell.duyuruResim.sd_setImage(with: URL(string: postBilgisi[indexPath.row].resimURL!))
                
                if postBilgisi[indexPath.row].dosyaAdi != "Seçili Dosya Yok" {
                    cell.isUserInteractionEnabled = true
                    cell.dosyaAdButton.tag = indexPath.row
                    cell.dosyaAdButton.titleLabel?.textColor = UIColor.blue
                    cell.dosyaAdButton.isSelected = false
                    cell.dosyaAdButton.setTitle(postBilgisi[indexPath.row].dosyaAdi, for: .normal)
                    if postBilgisi[indexPath.row].pdfURL != "" {
                        cell.dosyaAdButton.addTarget(self, action: #selector(anasayfaVC.pdfGoster), for: .touchUpInside)
                    }else {
                        cell.dosyaAdButton.addTarget(self, action: #selector(anasayfaVC.zipGoster), for: .touchUpInside)
                    }
                }else{
                    
                    cell.dosyaAdButton.isHidden = true
                }
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("duyuruCell2", owner: self, options: nil)?.first as! duyuruCell2
                let pictureTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                cell.duyuruResim.addGestureRecognizer(pictureTap)
                cell.ogretmenLabel.text = postBilgisi[indexPath.row].paylasanAdi + " & " + postBilgisi[indexPath.row].dersAdi
                cell.imageView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height*0.6)
                cell.selectionStyle = .none
                cell.delegate = self as? cell2delegate
                if postBilgisi[indexPath.row].odev == true {
                    cell.starpng.isHidden = false
                    //cell.isUserInteractionEnabled = true
                }else {
                    cell.starpng.isHidden = true
                    //cell.isUserInteractionEnabled = false
                }
                cell.baslikLabel.text = postBilgisi[indexPath.row].baslik?.uppercased()
                cell.tarihLabel.text = postBilgisi[indexPath.row].tarih
                cell.duyuruResim.sd_setImage(with: URL(string: postBilgisi[indexPath.row].resimURL!))
                if postBilgisi[indexPath.row].dosyaAdi != "Seçili Dosya Yok"{
                    cell.isUserInteractionEnabled = true
                    cell.dosyaAdButton.tag = indexPath.row
                    cell.dosyaAdButton.isSelected = false
                    cell.dosyaAdButton.titleLabel?.textColor = UIColor.blue
                    cell.dosyaAdButton.setTitle(postBilgisi[indexPath.row].dosyaAdi, for: .normal)
                    if postBilgisi[indexPath.row].pdfURL != "" {
                        cell.dosyaAdButton.addTarget(self, action: #selector(anasayfaVC.pdfGoster), for: .touchUpInside)
                    }else {
                        cell.dosyaAdButton.addTarget(self, action: #selector(anasayfaVC.zipGoster), for: .touchUpInside)
                    }
                }else{
                    cell.dosyaAdButton.isHidden = true
                }
                return cell
            }
        }
        else {
            let cell = Bundle.main.loadNibNamed("duyuruCell1", owner: self, options: nil)?.first as! duyuruCell1
          
            cell.ogretmenLabel.text = postBilgisi[indexPath.row].paylasanAdi + " & " + postBilgisi[indexPath.row].dersAdi
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height*0.6)
            cell.selectionStyle = .none
            cell.delegate = self as? cell1delegate
            if postBilgisi[indexPath.row].odev == true {
                cell.starpng.isHidden = false
               // cell.isUserInteractionEnabled = true
            }else {
               // cell.isUserInteractionEnabled = false
                cell.starpng.isHidden = true
            }
            cell.baslikLabel.text = postBilgisi[indexPath.row].baslik?.uppercased()
            cell.tarihLabel.text = postBilgisi[indexPath.row].tarih
            cell.aciklamaLabel.text = postBilgisi[indexPath.row].aciklama
            
            if postBilgisi[indexPath.row].dosyaAdi != "Seçili Dosya Yok"  {
                cell.isUserInteractionEnabled = true
                cell.dosyaAdButton.tag = indexPath.row
                cell.dosyaAdButton.titleLabel?.textColor = UIColor.blue
                cell.dosyaAdButton.setTitle(postBilgisi[indexPath.row].dosyaAdi!, for: .normal)
                cell.dosyaAdButton.isSelected = false
                if postBilgisi[indexPath.row].pdfURL != "" {
                    cell.dosyaAdButton.addTarget(self, action: #selector(anasayfaVC.pdfGoster), for: .touchUpInside)
                }else {
                    cell.dosyaAdButton.addTarget(self, action: #selector(anasayfaVC.zipGoster), for: .touchUpInside)
                }
            }else{
                
                cell.dosyaAdButton.isHidden = true
            }
        return cell
        }
    }
    
    func zipGoster(sender: UIButton ){
        
        let touchPoint = sender.convert(CGPoint.zero, to: self.duyuruTable)
        var clickedButtonIndexPath = duyuruTable.indexPathForRow(at: touchPoint)
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
    
        let touchPoint = sender.convert(CGPoint.zero, to: self.duyuruTable)
        var clickedButtonIndexPath = duyuruTable.indexPathForRow(at: touchPoint)
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
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "toPdfGoruntuleVC") as! pdfGoruntuleVC
                if  let urlString = self.fileLocalURLDict[0] {
                    vc.url = urlString
                    vc.gelenSayfaBilgisi = 1
                    self.navigationController?.pushViewController(vc, animated: false)
                    //self.performSegue(withIdentifier: "toPdfOlusturVC", sender: nil)
                }
            }
        }
    }
   

    func dersIDs(){
         self.dersID.removeAll()
      Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("dersler").observe(.childAdded, with: { (DataSnapshot) in
       
        if let values = DataSnapshot.value as? NSDictionary {
                let value = values["dersBilgisi"] as! NSDictionary
                print(value)
                self.dersID.append(value["ID"] as! String)
            print(self.dersID)
                }
        print(self.dersID)
        })
        print("Ders IDLERi")
        print(dersID)
        postData()
        print("postdata")
        dersID.removeAll()
        print(dersID)
    }
    func refreshUI() {
        DispatchQueue.main.async(execute: {
            self.duyuruTable.reloadData()
        });
    }
    
    func postData (){
    
     Database.database().reference().child("kullanicilar").queryOrdered(byChild: "Tarih").observe( .value, with: { (DataSnapshot) in
        self.postBilgisi.removeAll()
        
            let values = DataSnapshot.value as! NSDictionary
            let kullaniciID = values.allKeys
            for valuesID in kullaniciID {
                let kullanici = values[valuesID] as! NSDictionary
                if let derslerim = kullanici["derslerim"] as? NSDictionary {
                    let derslerId = derslerim.allKeys
                    for dersId in derslerId {
                        for dersid in self.dersID {
                            if dersid == dersId as! String {
                                let ders = derslerim[dersId] as! NSDictionary
                                if let postlar = ders["post"] as? NSDictionary {
                                    let postlarId = postlar.allKeys
                                    for postId in postlarId {
                                        let post = postlar[postId] as? NSDictionary
                                        let post1 = Post(postID: postId as! String, postData: post?["postBilgisi"] as! [String : AnyObject])
                                        self.postBilgisi.insert(post1, at: 0)
                                    }
                                }
                            }
                        }
                    }
                }
                self.refreshControl.endRefreshing()
                print(self.postBilgisi)
                self.duyuruTable.reloadData()
            }
        })
        print("postdata bitti")
        
    }
    @IBAction func cikisClicked(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        let signIn = self.storyboard?.instantiateViewController(withIdentifier: "girisVC") as! girisVC
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = signIn
        
        func applicationDidReceiveMemoryWarning(application: UIApplication) {
            URLCache.shared.removeAllCachedResponses()
        }
    }
}

