//
//  pdfGoruntuleVC.swift
//  Sanal Sınıf
//
//  Created by ibrahimdn on 13.03.2018.
//  Copyright © 2018 ibrahim. All rights reserved.
//

import UIKit

class pdfGoruntuleVC: UIViewController {
    var url : String = ""
    var gelenSayfaBilgisi = 0
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var geriGit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(gelenSayfaBilgisi)
        if gelenSayfaBilgisi == 1 {
            navigationBar.isHidden = true
            
            
        }
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var navigationBar: UINavigationBar!
    func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    @IBAction func geriClicked(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fileURL = URL(fileURLWithPath: self.url)
        let request = URLRequest(url: fileURL)
        
        self.webView.loadRequest(request)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
