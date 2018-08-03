//
//  post.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 4.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import Foundation

struct Post {
    
    let postId: String!
    var aciklama: String?
    var baslik: String?
    var tarih: String!
    var dosyaAdi: String?
    var pdfURL : String?
    var resimURL : String?
    var zipURL : String?
    var odev : Bool!
    var paylasan: String!
    var dersID: String!
    var odevTarihi: String?
    var paylasanAdi: String!
    var dersAdi: String!
    
    init (postID : String,postData: [String:AnyObject]){
        self.postId = postID
        if let dersAd = postData["dersAdi"] {
            self.dersAdi = dersAd as! String
        }
        if let paylasanAd = postData["paylasanAd"] {
            self.paylasanAdi = paylasanAd as! String
        }
        if let Baslik = postData["Baslik"] {
           self.baslik = Baslik as? String
        }
        if let Aciklama = postData["Aciklama"] {
            self.aciklama = Aciklama as? String
        }
        if let pdfurl = postData["PdfURL"] {
            self.pdfURL = pdfurl as? String
        }
        if let resimurl = postData["ResimURL"] {
            self.resimURL = resimurl as? String
        }
        if let zipurl = postData["ZipURL"] {
            self.zipURL = zipurl as? String
        }
        if let dosyaadi = postData["DosyaAdi"] {
            self.dosyaAdi = dosyaadi as? String
        }
        if let odevEkle = postData["odevEkle"] {
            self.odev = odevEkle as! Bool
        }
        if let paylasan = postData["Paylasan"]{
            self.paylasan = paylasan as! String
        }
        if let Tarih = postData["Tarih"] {
            self.tarih = Tarih as! String
        }
        if let dersid = postData["dersID"]{
            self.dersID = dersid as! String
        }
        if let odevTarih = postData["odevYuklemeTarihi"] {
            self.odevTarihi = odevTarih as? String
        }
    }
}
struct odev {
    let odevId: String!
    var tarih: String!
    var dosyaAdi: String?
    var pdfURL : String?
    var zipURL : String?
    var EkleyenKisiId: String!
    var EkleyenKisiAd: String!
  
    init (odevId : String,odevData: [String:AnyObject]){
        self.odevId = odevId
        if let pdfurl = odevData["PdfURL"] {
            self.pdfURL = pdfurl as? String
        }
        if let zipurl = odevData["ZipURL"] {
            self.zipURL = zipurl as? String
        }
        if let dosyaadi = odevData["DosyaAdi"] {
            self.dosyaAdi = dosyaadi as? String
        }
        if let EkleyenKisi = odevData["EkleyenKisiID"]{
            self.EkleyenKisiId = EkleyenKisi as! String
        }
        if let EkleyenKisiad = odevData["EkleyenKisiAd"]{
            self.EkleyenKisiAd = EkleyenKisiad as! String
        }
        if let Tarih = odevData["Tarih"] {
            self.tarih = Tarih as! String
        }
    }
}

struct ogrenciBilgi {
    let ogrenciID: String!
    var ogrenciAdi: String!
    var ogrenciOkulu: String!
    var ogrenciBolumu: String!
  
    init (ogrenciId: String,ogrenciData: [String:AnyObject]){
        self.ogrenciID = ogrenciId
        if let ogrenciAdi = ogrenciData["ad"] {
            self.ogrenciAdi = ogrenciAdi as? String
        }
        if let ogrenciOkulu = ogrenciData["okulu"] {
            self.ogrenciOkulu = ogrenciOkulu as? String
        }
        if let ogrenciBolumu = ogrenciData["bolumu"] {
            self.ogrenciBolumu = ogrenciBolumu as? String
        }
    }
}
struct sohbet {
    var isim: String!
    var mesaj: String!
    var tarih: String!
    var kullaniciId: String!
    
    init (kullaniciID: String, mesajData: [String:AnyObject]) {
        self.kullaniciId = kullaniciID
        if let Mesaj = mesajData["mesaj"] {
            self.mesaj = Mesaj as? String
        }
        if let Tarih = mesajData["time"] {
            self.tarih = Tarih as? String
        }
        if let ad = mesajData["ad"] {
            self.isim = ad as? String
        }
    }
}

