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
    var totalNoOfAlbums: Int = 0
   
    @IBOutlet weak var recordTitle: UILabel!

    @IBOutlet weak var wykonawca: UITextField!
    @IBOutlet weak var tytul: UITextField!
    @IBOutlet weak var gatunek: UITextField!
    @IBOutlet weak var rokWydania: UITextField!
    @IBOutlet weak var liczbaSciezek: UITextField! 
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var newRecordButton: UIButton!
    
    var isLast: Bool {
        get {
            return (currentAlbumIdx == totalNoOfAlbums)
        }
    }
    var isFirst: Bool {
        get {
            return (currentAlbumIdx == 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestInitialData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func newRecordClicked(_ sender: Any) {
        self.currentAlbumIdx = self.totalNoOfAlbums
        updateView()
    }

    private func updateView() {
        self.previousButton.isEnabled = !isFirst
        self.nextButton.isEnabled = !isLast
        self.newRecordButton.isEnabled = !isLast
        self.removeButton.isEnabled = !isLast
        self.saveButton.isEnabled = isLast
        
        if isLast {
            self.recordTitle.text = "Nowy Rekord"
            
            self.wykonawca.text = ""
            self.tytul.text = ""
            self.gatunek.text = ""
            self.rokWydania.text = ""
            self.liczbaSciezek.text = ""
        } else {
            self.recordTitle.text = "Rekord \(currentAlbumIdx + 1) z \(totalNoOfAlbums)"
            
            let currentAlbum = albums[currentAlbumIdx]
            self.wykonawca.text = currentAlbum.artist
            self.tytul.text = currentAlbum.album
            self.gatunek.text = currentAlbum.genre
            self.rokWydania.text = String(currentAlbum.year)
            self.liczbaSciezek.text = String(currentAlbum.tracks)
            
        }
        
    }
    
    private func requestInitialData() {
        let session = URLSession.shared
        let url = URL.init(string: "https://isebi.net/albums.php")
        
        session.dataTask(with: url!, completionHandler: { (maybeData: Data?, _, _) in
            if let data = maybeData,
                let maybeJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                let json = maybeJson {
                    for album in json {
                        if let album = Album(json: album) {
                            self.albums.append(album)
                            print("Adding album \(album)")
                        }
                    }
                    self.totalNoOfAlbums = self.albums.count
            } else {
                print("Couldn't deserialize \(maybeData)")
            }
            
            
            DispatchQueue.main.async {
                self.updateView()
            }
        }).resume()
        
    }
    @IBAction func nextClicked(_ sender: Any) {
        currentAlbumIdx = (currentAlbumIdx + 1)
        updateView()
    }
    
    @IBAction func previousClicked(_ sender: Any) {
        currentAlbumIdx = (currentAlbumIdx - 1)
        updateView()
    }
    
    @IBAction func removeClicked(_ sender: Any) {
        albums.remove(at: currentAlbumIdx)
        totalNoOfAlbums -= 1
        updateView()
    }
    
    @IBAction func addClicked(_ sender: Any) {
        let newAlbum = Album(
            artist: wykonawca.text ?? "",
            album: tytul.text ?? "",
            genre: gatunek.text ?? "",
            year: Int(rokWydania.text ?? "") ?? 0,
            tracks: Int(liczbaSciezek.text ?? "") ?? 0
        )
        if (isLast) {
            albums.append(newAlbum)
            self.totalNoOfAlbums += 1
        } else {
            albums[currentAlbumIdx] = newAlbum
        }
        updateView()
    }
  
    @IBAction func editingBegun(_ sender: UITextField) {
        self.saveButton.isEnabled = true
    }

    
   
}

