//
//  Mission.swift
//  RW - Paper
//
//  Created by Kevin Khieu on 2/18/18.
//  Copyright © 2018 -. All rights reserved.
//


import Foundation
import UIKit

class Mission {
    
    convenience init (intro: String, curr: Int, type: Int) {
        self.init()
        self.introText = intro
        self.state = curr
        self.pageType = type
        self.introTexts.append("Use your jumping jacks powers to help Spidey save the world! Let's do 10!")
        self.introTexts.append("You have super speed! Run in place for 20 seconds to catch up with Spiderman!")
        self.introTexts.append("You're fighting alongside these heros! Do 10 jumping jacks to win!")
        self.introTexts.append("Run from the enemy for 20 seconds to escape!")
    }
    
    var introText: String = ""
    var introTexts: [String] = []
    var title: String = "Save the world!"
    var characterId: Int = 0
    var bgImg: UIImage? = nil
    
    var state: Int = 0      // 0 = not started, 1 = started, 2 = finished
    var pageType: Int = 0   // 0 = Jumping Jacks, 1 = Running, 2 = Shaking iPad
    
    func getState() -> Int {
        return self.state
    }
    
    func getPageType() -> Int {
        return self.pageType
    }
    
    func setIntroText() {
        self.introText = self.introTexts[((pageType * (state + 1)) % self.introTexts.count) + 2]
    }
    
    func getIntroText() -> String {
        return self.introText
    }
    
    func getImage() -> UIImage {
        return self.bgImg!
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func setImage(img: UIImage) {
        self.bgImg = img
    }
    
    func setCharacterId(id: Int) {
        self.characterId = id
    }
    
    func setIntroText(text: String) {
        self.introText = text
    }
    
}
