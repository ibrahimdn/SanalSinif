//
//  duyuruEkleVC.swift
//  
//
//  Created by ibrahimdn on 26.12.2017.
//
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import CoreData
import MBProgressHUD
@available(iOS 10.0, *)
class duyuruEkleVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var dosyaSecimi = Int()
    var resimURL : String = ""
    var pdfDownloadURL : String = ""
    var zipURL : String = ""
    var dosyaAdi = String()
    var dosyaURL = NSURL()
    var uuid = NSUUID().uuidString
    var duyuruSecilenDers = String()
    var kullaniciAdi = String()
    let picker = UIImagePickerController()
    let secilenResim = UIImageView()
    let defaults = UserDefaults.standard
    let timestamp = ServerValue.timestamp()
    let datePicker = UIDatePicker()
    var dersAdi = String()
    var secilmisDers = NSUUID()
    var odevYuklemeTarih = Date()
    var toolBar = UIToolbar()
  
    @IBOutlet weak var odevTarihText: UITextField!
    @IBOutlet weak var odevEkleSwitchCilcked: UISwitch!
    @IBOutlet weak var duyuruBaslik: UITextField!
    @IBOutlet weak var dosyaEkleClicked: UIButton!
    @IBOutlet weak var duyuruResim: UIImageView!
    @IBOutlet weak var duyuruText: UITextView!
    @IBOutlet weak var dosyaIsımLabel: UILabel!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        odevTarihText.isHidden = true
        kullaniciAd()
        dersAd()
        getUserDefaults()
        duyuruText.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        duyuruText.layer.borderWidth = 1.0
        duyuruText.layer.cornerRadius = 5
        
       if kullaniciAdi.isEmpty {
            if defaults.object(forKey: "kullaniciAdi") != nil {
                kullaniciAdi = defaults.object(forKey: "kullaniciAdi") as! String
            }
        }else {
            defaults.set(kullaniciAdi, forKey: "kullaniciAdi")
        }
        if duyuruSecilenDers.isEmpty {
            duyuruSecilenDers = defaults.object(forKey: "duyuruSecilenDers") as! String
        }else{
            defaults.set(duyuruSecilenDers, forKey: "duyuruSecilenDers")
        }
        print("view \(dosyaAdi)")
        print("view \(dosyaURL)")
        if dosyaAdi != "" {
            dosyaIsımLabel.text = dosyaAdi
        }
        self.navigationController?.isNavigationBarHidden = false
        duyuruResim.isUserInteractionEnabled = true
        let resimKaydet = UITapGestureRecognizer(target: self, action: #selector(duyuruEkleVC.fotoSec))
        duyuruResim.addGestureRecognizer(resimKaydet)
    }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillAppear(animated)
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
            setUserDefaults()
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
            getUserDefaults()
        }else{
            let alert = UIAlertController(title: "", message: "Kamera bulunamadı", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
    func galeriButton(){
        setUserDefaults()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        getUserDefaults()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        duyuruResim.image = info[UIImagePickerControllerEditedImage] as? UIImage
        secilenResim.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func odevEkleSwitchClicked(_ sender: UISwitch) {
        if odevEkleSwitchCilcked.isOn {
            odevTarihText.isHidden = false
            toolBar.sizeToFit()
            let tamam = UIBarButtonItem(title: "Tamam", style: .done, target: nil, action: #selector(tamamClicked))
            toolBar.setItems([tamam], animated: true)
            odevTarihText.inputAccessoryView = toolBar
            odevTarihText.inputView = datePicker
        }else {
            odevTarihText.isHidden = true
        }
        
        
    }
    func tamamClicked(){
       // setUserDefaults()
        odevTarihText.text = "\(datePicker.date)"
        self.view.endEditing(true)
        //setUserDefaults()
    }

    func surecIzleme() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.annularDeterminate
        return hud
    }
    func kullaniciAd(){
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
    }
    func dersAd ()  {
        let uid = Auth.auth().currentUser?.uid
        if defaults.object(forKey: "duyuruSecilenDers") != nil {
            duyuruSecilenDers = defaults.object(forKey: "duyuruSecilenDers") as! String
        }
        Database.database().reference().child("kullanicilar").child(uid!).child("derslerim").child(duyuruSecilenDers).observe(.childAdded, with: { (snapshot) in
            let values = snapshot.value as! NSDictionary
            let keys = values.allKeys
            for key in keys {
                if key as! String == "ad" {
                    print(values[key]!)
                    self.dersAdi = values[key] as! String
                }
            }
        })
    }
    
    @IBAction func paylasClicked(_ sender: UIButton) {
        let uuid = NSUUID(uuidString: duyuruSecilenDers)
        if duyuruBaslik.text != "" {
            let dataRef = Database.database().reference().child("kullanicilar").child((Auth.auth().currentUser?.uid)!).child("derslerim").child(defaults.object(forKey: "duyuruSecilenDers") as! String).child("post").childByAutoId().child("postBilgisi")
        
            var butunData = ["Baslik": duyuruBaslik.text! ,"ResimURL" : "" , "PdfURL" : "" ,"ZipURL": "", "Aciklama" : duyuruText.text , "Tarih" : tarih(),"EklenmeTarihi" :  timestamp , "Paylasan" : Auth.auth().currentUser?.uid as Any ,"DosyaAdi" :dosyaIsımLabel.text!,"odevEkle": odevEkleSwitchCilcked.isOn,"odevYuklemeTarihi" : odevTarihText.text!, "dersID": duyuruSecilenDers,"dersAdi": dersAdi, "paylasanAd": kullaniciAdi] as [String: Any]
        
            if let data = UIImageJPEGRepresentation(duyuruResim.image!, 0.5) {
                if let emptyImage = UIImage(named: "resimSec.png") {
                    let emptyData = UIImagePNGRepresentation(emptyImage)
                    let compareImage = UIImagePNGRepresentation(duyuruResim.image!)
                    if let empty = emptyData , let CompareTo = compareImage {
                        if !empty.elementsEqual(CompareTo) {
                             let hudResim = surecIzleme()
                             hudResim.label.text = "Resim Yükleniyor..."
                             let mediaResim = Storage.storage().reference().child("resim").child("\(String(describing: uuid)).jpg").putData(data, metadata: nil, completion: { (metadata, error) in
                                if error != nil {
                                    let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                 }else {
                                    self.resimURL = (metadata?.downloadURL()?.absoluteString)!
                                    butunData["ResimURL"] = self.resimURL
                                    dataRef.setValue(butunData)
                                }
                            })
                            mediaResim.observe(.progress, handler: { (snapshot) in
                                guard let progress = snapshot.progress else {return}
                                hudResim.progress = Float(progress.fractionCompleted)
                            })
                            mediaResim.observe(.success, handler: { (snapshot) in
                                hudResim.hide(animated: true)
                            })
                        }
                    }
                }
                if dosyaURL.isFileURL {
                    let hudDosya = surecIzleme()
                    hudDosya.label.text = "Dosya yükleniyor..."
                    let doc = UIDocument(fileURL: self.dosyaURL as URL)
                    let pdfDosyasi = Storage.storage().reference().child("pdf").child("\(self.uuid)").putFile(from: doc.fileURL as URL , metadata: nil) { metadata, error in
                    
                        if (error != nil) {
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }else {
                            self.pdfDownloadURL = (metadata!.downloadURL()?.absoluteString)!
                            if self.dosyaAdi.hasSuffix(".pdf") {
                                butunData["PdfURL"] = self.pdfDownloadURL
                            }else {
                                //hem pdf url hem de zip url için pdfDownloadURL kullanıldı...
                                butunData["ZipURL"] = self.pdfDownloadURL
                            }
                            dataRef.setValue(butunData)
                        }
                    }
                    pdfDosyasi.observe(.progress, handler: { (snapshot) in
                        guard let progress = snapshot.progress else {return}
                        hudDosya.progress = Float(progress.fractionCompleted)
                    })
                    pdfDosyasi.observe(.success, handler: { (snapshot) in
                        hudDosya.hide(animated: true)
                    })
                } else {
                    dataRef.setValue(butunData)
                }
                duyuruText.text = ""
                duyuruBaslik.text = ""
                odevTarihText.text = ""
                odevTarihText.isHidden = true
                duyuruResim.image = #imageLiteral(resourceName: "resimSec.png")
                self.tabBarController?.selectedIndex = 0
                resetDefaults()
                }
        }else {
            let alert = UIAlertController(title: "Hata!", message: "Başlık boş bırakılamaz.", preferredStyle: .alert)
            let alertButon = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
            alert.addAction(alertButon)
            self.present(alert, animated: true, completion: nil)
        }
        
       
    }
    func setUserDefaults(){
        defaults.set(duyuruBaslik.text, forKey: "duyuruBaslik")
        defaults.set(duyuruText.text, forKey: "duyuruText")
        defaults.set(odevEkleSwitchCilcked.isOn, forKey: "odevSwitch")
        if odevTarihText.text != nil {
            defaults.set(odevTarihText.text, forKey: "tarih")
        }
        /*if dosyaURL.isFileURL {
            defaults.set(dosyaURL, forKey: "dosyaURL")
        }*/
        defaults.set(dosyaAdi, forKey: "dosyaAd")
        defaults.set(kullaniciAdi, forKey: "kullaniciAdi")
        defaults.set(dersAdi, forKey: "dersAdi")
        
        
    }
    func getUserDefaults(){
        if defaults.object(forKey: "duyuruBaslik") != nil {
            duyuruBaslik.text = defaults.object(forKey: "duyuruBaslik") as? String
        }
        if defaults.object(forKey: "duyuruText") != nil {
            duyuruText.text = defaults.object(forKey: "duyuruText") as! String
        }
        if defaults.object(forKey: "kullaniciAdi") != nil {
            kullaniciAdi = defaults.object(forKey: "kullaniciAdi") as! String
        }
        if defaults.object(forKey: "dersAdi") != nil {
            dersAdi = defaults.object(forKey: "dersAdi") as! String
        }
        if defaults.object(forKey: "odevSwitch") != nil {
            odevEkleSwitchCilcked.isOn = defaults.object(forKey: "odevSwitch") as! Bool
        }
        if defaults.object(forKey: "tarih") != nil {
            odevTarihText.isHidden = false 
            odevTarihText.text = defaults.object(forKey: "tarih") as? String
        }
    }
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setUserDefaults()
        let destController : popOverDersTableVC = segue.destination as! popOverDersTableVC
        destController.tableGosterimi = dosyaSecimi
        getUserDefaults()
    }
    
    func tarih() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let result = formatter.string(from: date)
        return result
    }
    
    @IBAction func dosyaEkleClicked(_ sender: UIButton) {
        setUserDefaults()
        dosyaSecimi = dosyaEkleClicked.tag
        print("tus secimi \(dosyaEkleClicked.tag)")
        performSegue(withIdentifier: "toDosyaEklePop", sender: nil)
        getUserDefaults()
       // list2()
    }
    
    func list2 (){
       
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
           
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(documentsUrl)
            
            
            for item in directoryContents
            {
                print("item = \(item)")
           
                if item.path.hasSuffix("pdf")
                {
                    print("path : \(item.path)")
                    let storageRef = Storage.storage().reference()
                    let localFile = item as NSURL
               
                    print(localFile)
                  
                    let doc = UIDocument(fileURL: localFile as URL)
                    print(doc.fileURL)
                    _ = storageRef.child("pdf").child("\(uuid)").putFile(from: doc.fileURL as URL , metadata: nil) { metadata, error in
                        if (error != nil) {
                            let alert = UIAlertController(title: "HATA", message: error?.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            
                            let downloadURL = metadata!.downloadURL()
                            print(downloadURL!)
                        }
                    }
                }
            }
            
            
        }catch{
            print(error.localizedDescription)
        }
    //    let storage = Storage.storage().reference().child("pdf")
      
     //   let riversRef = storage.child("pdf/1.pdf")
           
        //conten ile dizi elde etme
        
        /*if  let filePath = Bundle.main.path(forResource: file, ofType: fileType) {
            do {
                
            let content = try String(contentsOfFile: filePath)
            print(content)
            }catch{
                
                print("HATA")
            }
        }*/
        
  
        /*if let fileURL = Bundle.main.path(forResource: file, ofType: fileType, inDirectory: "filesSubDirectory") {
            
            print(fileURL)
          
        }
        if let fileURL = Bundle.main.url(forResource: file, withExtension: fileType, subdirectory: "filesSubDirectory") {
            print("BUNDLE")
            print(fileURL)
            let upload = riversRef.putFile(from: fileURL as URL, metadata: nil) { (meta, error) in
                
                if let error = error {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = meta!.downloadURL()
                }
        }

        }
  
        */

        // NS BUNDNLE dosya isminden dosya yolunun bulunması ....
       /* let file = "2017-2018_Gu%CC%88z-Final_Web.pdf"
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first as NSString? {
            //path will be stored here
            let sPath = dir.appendingPathComponent(file);
            let documentsURL = NSURL(
                fileURLWithPath: NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true).first!,
                isDirectory: true
            )
            let URLToMyFile = documentsURL.appendingPathComponent("2017-2018_Gu%CC%88z-Final_Web.pdf")
            print("dosya bulundu \(sPath)") //  printing the file path
            print("2. dosya yolu \(URLToMyFile!.path)")
            let storageRef = Storage.storage().reference()
            
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("pdf")
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putFile(from: URLToMyFile!, metadata: nil) { metadata, error in
                if let error = error {
                print("HATA")
                print(error.localizedDescription)
                } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()
                }
            }

        }*/
        //bundle main
        /*//let bundle  = Bundle.main
       // print(bundle.path(forResource: "file:///Users/ibrahimdn/Library/Developer/CoreSimulator/Devices/CD7D2A3A-5863-4E01-874A-344C9668DD39/data/Containers/Data/Application/162CB5C3-3E9C-4730-A752-17EC1E315BFB/Documents/2017-2018_Gu%CC%88z-Final_Web.pdf", ofType: "pdf"))*/
        
          //Asset ile dosya yolunu alma
       /* PHasset.requestContentEditingInput(with: nil, completionHandler: {(contentEditingInput: PHContentEditing, info: [AnyHashable : Any]) -> Void in
            
        
            let originalFileUrl = contentEditingInput!.fullSizeImageURL!
            
            /* Copy file from photos app to documents directory */
            let fileManager = FileManager.default
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let destinationPath = documentsDirectory.appendingPathComponent(originalFileUrl.lastPathComponent)
            let destinationUrl = URL(fileURLWithPath: destinationPath)
            
            do {
                try fileManager.copyItem(at: originalFileUrl, to: destinationUrl)
            }
            catch {
                print("Unable to copy file from photos to documents directory (run out of space on device?)")
                return
            }
            
            /* Create metadata etc. for Firebase... */
            
            /* Upload file to Firebase */
            fileRef.putFile(from: destinationUrl, metadata: metadata, completion: { (metadata, error) in
                
                // Remove the file from the documents directory
                do {
                    try fileManager.removeItem(at: destinationUrl)
                }
                catch {
                    print("Unable to remove file from documents directory")
                }
                
            })
            
            
        })*/
        
        
        // listeliyeme kısmı
        
        /*
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        print(documentsUrl.path)
    
        do {
           
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print("dosya pathi")
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let pdfFiles = directoryContents.filter{ $0.pathExtension == "pdf" }
            print("pdfFiles")
            print(pdfFiles)
      
            
            let pdfFileNames = pdfFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("pdf File Name")
            print( pdfFileNames)
            
                        // File located on disk
            
            let localFile = URL(string: "file:///Users/ibrahimdn/Library/Developer/CoreSimulator/Devices/CD7D2A3A-5863-4E01-874A-344C9668DD39/data/Containers/Data/Application/162CB5C3-3E9C-4730-A752-17EC1E315BFB/Documents/2017-2018_Gu%CC%88z-Final_Web.pdf")!

            print("local Fİle  = \(localFile)")
            let storageRef = Storage.storage().reference().child("pdf")
            // Create a reference to the file you want to upload
            
            
            // Upload the file to the path "images/rivers.jpg"
            _ = storageRef.putFile(from: localFile , metadata: nil) { metadata, error in
                if error != nil {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    _ = metadata!.downloadURL()
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
       
        
 
     
        let data : NSData = NSData(contentsOf: ("file:///Users/ibrahimdn/Library/Developer/CoreSimulator/Devices/CD7D2A3A-5863-4E01-874A-344C9668DD39/data/Containers/Data/Application/0D2C2E7B-F404-43FE-B0A7-301AF6BE9D1F/Documents/1.pdf" as! NSURL) as URL)
        let url : NSURL = NSURL(fileURLWithPath: "file:///Users/ibrahimdn/Library/Developer/CoreSimulator/Devices/CD7D2A3A-5863-4E01-874A-344C9668DD39/data/Containers/Data/Application/0D2C2E7B-F404-43FE-B0A7-301AF6BE9D1F/Documents/1.pdf" as String)
        
        let storageRef = Storage.storage().reference()
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("pdf")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putFile(from: url as URL, metadata: nil) { metadata, error in
            if let error = error {
                print("HATA")
                print(error.localizedDescription)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()
            }
        }*/
    }

   
    
    @IBAction func geriClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
  

}
