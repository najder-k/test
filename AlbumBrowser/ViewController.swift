//
//  ViewController.swift
//  AlbumBrowser
//
//  Created by Użytkownik Gość on 10.10.2017.
//  Copyright © 2017 agh. All rights reserved.
//

import UIKit

class Album: NSObject, NSCoding {
    let artist: String
    let album: String
    let genre: String
    let year: Int
    let tracks: Int
    
    init(_ artist: String, _ album: String, _ genre: String, _ year: Int, _ tracks: Int) {
        self.artist = artist
        self.album = album
        self.genre = genre
        self.year = year
        self.tracks = tracks
    }
    
    required convenience init?(json: [String: Any]) {
        guard let artist = json["artist"] as? String,
            let album = json["album"] as? String,
            let genre = json["genre"] as? String,
            let year = json["year"] as? Int,
            let tracks = json["tracks"] as? Int
            else {
                return nil
        }
        
        self.init(artist, album, genre, year, tracks)
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let artist = decoder.decodeObject(forKey: "artist") as? String,
            let album = decoder.decodeObject(forKey: "album") as? String,
            let genre = decoder.decodeObject(forKey: "genre") as? String
            else {
                return nil
        }
        let year = decoder.decodeInteger(forKey: "year")
        let tracks = decoder.decodeInteger(forKey: "tracks")
        
        self.init(artist, album, genre, year, tracks)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.artist, forKey: "artist")
        aCoder.encode(self.album, forKey: "album")
        aCoder.encode(self.genre, forKey: "genre")
        aCoder.encode(self.year, forKey: "year")
        aCoder.encode(self.tracks, forKey: "tracks")
    }
    
    override public var description: String {
        return "Album(\(artist), \(album), \(genre), \(year), \(tracks))"
    }
    
}

class ViewController: UIViewController {
    
    var albums = [Album]()
    var currentAlbumIdx: Int = 0
    var totalNoOfAlbums: Int = 0
    
    var filePath : String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return path + "/albums"
    }
   
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
        loadData()
    }
    
    private func loadData() {
        if let cachedAlbums = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Album] {
            print("Loading cached albums")
            print(cachedAlbums)
            albums = cachedAlbums
            totalNoOfAlbums = albums.count
            updateView()
        } else {
            print("Requesting data from server")
            requestInitialData()
        }
    }
    
    private func saveData() {
        if NSKeyedArchiver.archiveRootObject(albums, toFile: filePath) {
            print("Successfully saved album data");
        } else {
            print("Error in saving albums");
        }
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
        
        session.dataTask(with: url!, completionHandler: { (maybeData: Data?, _, error) in
            if let error = error {
                print("An error occured during the request: \(error.localizedDescription)")
            }
            
            if let data = maybeData,
                let maybeJson = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                let jsonList = maybeJson {
                    for json in jsonList {
                        if let album = Album(json: json) {
                            self.albums.append(album)
                            print("Adding album \(album.album)")
                        }
                    }
                    self.totalNoOfAlbums = self.albums.count
            } else {
                print("Couldn't deserialize \(maybeData)")
            }
            

            DispatchQueue.main.async {
                self.saveData()
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
            wykonawca.text ?? "",
            tytul.text ?? "",
            gatunek.text ?? "",
            Int(rokWydania.text ?? "") ?? 0,
            Int(liczbaSciezek.text ?? "") ?? 0
        )
        if (isLast) {
            albums.append(newAlbum)
            self.totalNoOfAlbums += 1
        } else {
            albums[currentAlbumIdx] = newAlbum
        }
        
        saveData()
        updateView()
    }
  
    @IBAction func editingBegun(_ sender: UITextField) {
        self.saveButton.isEnabled = true
    }

    
   
}

