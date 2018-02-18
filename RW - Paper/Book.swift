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

class Book {

    convenience init (cover: String, pages: [String]) {
        self.init()
        self.dict["cover"] = cover
        self.dict["pages"] = pages
    }
    
    var dict: Dictionary<String, Any> = Dictionary<String, Any>()
    var story: Bool = true
    var miss: [Mission] = []
    
    func setMission() {
        self.story = false
    }
    
    func addMission(mission: Mission) {
        self.miss.append(mission)
    }
    
    func updatePages(pages: [String]) {
        self.dict["pages"] = pages
    }
    
    func coverImage () -> UIImage? {
        if let cover = dict["cover"] as? String {
            return UIImage(named: cover)
        }
        return nil
    }
    
    func pageImage (_ index: Int) -> UIImage? {
        if self.miss.count > index {
            return self.miss[index].bgImg
        }
        
        if self.miss.count == 0, let pages = dict["pages"] as? NSArray {
            if let page = pages[index] as? String {
                return UIImage(named: page)
            }
        }
        return nil
    }
    
    func pageTitle(_ index: Int) -> String? {
        return self.miss[index].title
    }
    
    func pageIntro(_ index: Int) -> String? {
        return self.miss[index].introText
    }
    
    func pageState(_ index: Int) -> Int? {
        return self.miss[index].state
    }
    
    func numberOfPages () -> Int {
        if self.miss.count > 0 {
            return self.miss.count
        }
        if let pages = dict["pages"] as? NSArray {
            return pages.count
        }
        return 0
    }
    
    func addPage() {
        if self.story == true {
            //self.dict!["pages"].append(")
        }
    }
    
}
