//
//  CoreData.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 1.02.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//
/*
import UIKit
import CoreData
@available(iOS 10.0, *)
class CoreData: NSObject {

    
    class func getContext() -> NSManagedObjectContext{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
    class func objeKaydetme(baslik:String, aciklama:String ) -> ObjCBool{
     
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Duyuru", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        manageObject.setValue(baslik, forKey: "baslik")
        manageObject.setValue(aciklama, forKey: "aciklama")
        
        do{
            try context.save()
            return true
            
        }catch {
            return true
        }
        
    }
    class func objeKaydetme(resim:UIImage)-> ObjCBool{
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Duyuru", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        manageObject.setValue(resim, forKey: "resim")
        
        do{
            try context.save()
            return true
            
        }catch {
            return true
        }

    }
    class func zipKaydet(zipURL:NSURL)-> ObjCBool{
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Duyuru", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        manageObject.setValue(zipURL, forKey: "zipURL")
        
        do{
            try context.save()
            return true
            
        }catch {
            return true
        }
    }
    class func pdfKaydet(pdfURL:NSURL)-> ObjCBool{
            let context = getContext()
            let entity = NSEntityDescription.entity(forEntityName: "Duyuru", in: context)
            let manageObject = NSManagedObject(entity: entity!, insertInto: context)
            manageObject.setValue(pdfURL, forKey: "pdfURL")
            
            do{
                try context.save()
                return true
                
            }catch {
                return true
            }


    }
    
}
*/
