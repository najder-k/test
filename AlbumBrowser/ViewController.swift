//
//  ViewController.swift
//  AlbumBrowser
//
//  Created by Użytkownik Gość on 10.10.2017.
//  Copyright © 2017 agh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var albumData = [String: Any]()
    var currentAlbum: String? = ""
    
    @IBOutlet weak var recordTitle: UILabel!

    @IBOutlet weak var wykonawca: UITextField!
    @IBOutlet weak var tytul: UITextField!
    @IBOutlet weak var gatunek: UITextField!
    @IBOutlet weak var rokWydania: UITextField!
    @IBOutlet weak var liczbaSciezek: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestInitialData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func requestInitialData() {
        let session = URLSession.shared
        let url = URL.init(string: "https://isebi.net/albums.php")
        
        session.dataTask(with: url!, completionHandler: {
            (maybeData: Data?, response: URLResponse?, err: Error?) in
            
            guard let data = maybeData else { print("NI MA"); return }
            let thing = try? JSONSerialization.jsonObject(with: data)
            guard let foo = thing else { print("NI MA"); return }
            self.albumData = foo as! [String: Any]
            DispatchQueue.main.async {
//                self.currentAlbum = self.albumData.first.key
                
            }

        })
    }
    
    
    

}

