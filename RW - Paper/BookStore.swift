/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class BookStore {

    private static var __once: () = {
            var instance = BookStore()
        }()

    class var sharedInstance : BookStore {
        struct Static {
            static var onceToken : Int = 0
            static var instance : BookStore? = nil
        }
        
        _ = BookStore.__once
        
        return BookStore()
    }
    
    
    var numMissions: Int = 10
    var missions: [Mission] = []
    var adventures: [Mission] = []
    var missionsBook: Book = Book()
    var adventuresBook: Book = Book()
    
    func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func downloadImage(url: URL, index: Int, title: String!) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.missions[index].setImage(img: UIImage(data: data)!)
                self.missionsBook.setMission()
                self.missions[index].setTitle(title: title)
                self.missions[index].pageType = index % 2
                self.missions[index].setIntroText()
                if index == 0 {
                    self.missions[index].state = 1
                } else {
                    self.missions[index].state = 0
                }
                self.missionsBook.addMission(mission: self.adventures[index])
                
                self.adventures[index].setImage(img: UIImage(data: data)!)
                self.adventures[index].setTitle(title: title)
                self.adventures[index].pageType = index % 2
                self.adventures[index].setIntroText()
                if index == 0 {
                    self.adventures[index].state = 1
                } else {
                    self.adventures[index].state = 0
                }
                self.adventuresBook.addMission(mission: self.adventures[index])
            }
        }
    }
    
    
    func getPage() {
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let time = "\(hour)\(minutes)\(seconds)"
        let url = time + "3c755041b750130203b6142834f2b7a4fc31c8ad" + "70b975aa9c3be60c23bc6f66f941581e"
        
        let md5Data = MD5(string: url)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        let finalUrl = "https://gateway.marvel.com:443/v1/public/comics?" + "ts=" + time + "&apikey=70b975aa9c3be60c23bc6f66f941581e&hash=" + md5Hex + "&limit=100"
        
        var request = URLRequest(url: URL(string: finalUrl)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        
        //Make request
        session.dataTask(with: request) {data, response, err in
            if(err != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let jsonData = json["data"] as! [String:AnyObject]
                    var count = 0
                    let arr = (jsonData["results"] as! NSArray)
                    for val in arr {
                        if count < self.missions.count {
                            let dict = val as! NSDictionary
                            for (key, value) in dict{
                                if key as! String == "thumbnail"{
                                    let v = value as! [String:String]
                                    if v["path"]!.lowercased().range(of:"image") == nil {
                                        print(dict["title"]!)
                                        let imgUrl = v["path"]! + "/portrait_xlarge." + v["extension"]!
                                        self.downloadImage(url: URL(string: imgUrl)!, index: count, title: dict["title"]! as! String)
                                        //self.missions[count].setCharacterId(id: <#T##Int#>)
                                        count += 1
                                        break
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                }catch let error as NSError{
                    print("JSON ERROR")
                    print(error)
                }
            }
            }.resume()
    }
    
    func loadBooks(_ plist: String) -> [Book] {
        var books: [Book] = []
        
        if let path = Bundle.main.path(forResource: plist, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) {
                var missionsDict = Dictionary<String, Any>()
                for i in 0 ... numMissions {
                    self.missions.append(Mission(intro: "", curr: 0, type: 0))
                }
                missionsDict["cover"] = "missions_cover"
                missionsDict["missions"] = missions
                let pages: [String] = []
                missionsBook = Book(cover: missionsDict["cover"] as! String, pages: pages)
                books += [missionsBook]
                
                var adventureDict = Dictionary<String, Any>()
                for i in 0 ... numMissions {
                    self.adventures.append(Mission(intro: "", curr: 0, type: 0))
                }
                adventureDict["missions"] = adventures
                adventureDict["cover"] = "adventure_cover"
                let pages2: [String] = []
                adventuresBook = Book(cover: adventureDict["cover"] as! String, pages: pages2)
                books += [adventuresBook]
                getPage()
                
            }
        }
        
        return books
    }
    
}
