//
//  ViewController.swift
//  AlbumBrowser
//
//  Created by Użytkownik Gość on 10.10.2017.
//  Copyright © 2017 agh. All rights reserved.
//

import UIKit

struct Album {
    let artist: String
    let album: String
    let genre: String
    let year: Int
    let tracks: Int
}
extension Album {
    init?(json: [String: Any]) {
        guard let artist = json["artist"] as? String,
            let album = json["album"] as? String,
            let genre = json["genre"] as? String,
            let year = json["year"] as? Int,
            let tracks = json["tracks"] as? Int
        else {
            return nil
        }
        
        self.artist = artist
        self.album = album
        self.genre = genre
        self.year = year
        self.tracks = tracks
    }
}

class ViewController: UIViewController {
    
    var albums = [Album]()
    var currentAlbumIdx: Int = 0
   
    
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

    private func updateView() {
        let currentAlbum = albums[currentAlbumIdx]
        self.wykonawca.text = currentAlbum.artist
        self.tytul.text = currentAlbum.album
        self.gatunek.text = currentAlbum.genre
        self.rokWydania.text = String(currentAlbum.year)
        self.liczbaSciezek.text = String(currentAlbum.tracks)
        
        self.recordTitle.text = currentAlbum.album
    }
    
    private func requestInitialData() {
        let session = URLSession.shared
        let url = URL.init(string: "https://isebi.net/albums.php")
        
        session.dataTask(with: url!, completionHandler: {
            (maybeData: Data?, _, _) in
            
        
            if let data = maybeData,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] { //lista tablic asocjacyjnych
                    for album in json! {
                        if let album = Album(json: album) {
                            self.albums.append(album)
                            print("Adding album \(album)")
                        }
                    }
            }
            
            
            DispatchQueue.main.async {
                self.updateView()
            }
        }).resume()
        
    }
    @IBAction func nextClicked(_ sender: Any) {
        currentAlbumIdx = (currentAlbumIdx + 1) % albums.count
        updateView()
    }
    
    @IBAction func previousClicked(_ sender: Any) {
        currentAlbumIdx = (currentAlbumIdx - 1) % albums.count
        updateView()
    }
    
    

}

