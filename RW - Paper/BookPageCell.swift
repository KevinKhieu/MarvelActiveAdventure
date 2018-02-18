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
import UserNotifications
import AVFoundation
import AVKit

class BookPageCell: UICollectionViewCell {
	

    @IBOutlet weak var Intro: UILabel!
    @IBOutlet weak var title: UILabel!
	@IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var lockedImg: UIImageView!
    @IBOutlet weak var completedImg: UIImageView!
    
    
    
    @IBOutlet weak var button: UIButton!
    
    var parentContainer: UICollectionViewController? = nil
    var running: Bool = false
    func setTitle(title: String) {
        self.title.text = title
    }
    
    func setIntro(title: String) {
        self.Intro.text = title
    }
    
    func hideStuff() {
        self.Intro.isHidden = true
        self.title.isHidden = true
    }
    
    func setNotStarted() {
        //self.hideStuff()
        self.lockedImg.isHidden = false
        self.completedImg.isHidden = true
    }
    
    func setCompleted() {
        //self.hideStuff()
        self.completedImg.isHidden = false
        self.lockedImg.isHidden = true
        print("SET COMPLETD")
    }
    
    func setActive() {
        self.completedImg.isHidden = true
        self.lockedImg.isHidden = true
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        showVideo()
    }
    
    func showVideo() {
        var resourceName: String?
        if self.running == true {
            resourceName = "spiderman"
        } else {
            resourceName = "running"
        }
        guard let path = Bundle.main.path(forResource: resourceName, ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        //let player = AVPlayer(URL: URI)
        let controller = AVPlayerViewController()
        controller.player = player
        self.parentContainer?.addChildViewController(controller)
        let screenSize = UIScreen.main.bounds.size
        let videoFrame = CGRect(x: 0 + ((screenSize.width - (screenSize.width * 0.7)) / 2), y: ((screenSize.height - (screenSize.height * 0.7)) / 2), width: screenSize.width * 0.7, height: 0.7 * (screenSize.height))
        controller.view.frame = videoFrame
        controller.view.tag = 100
        self.parentContainer?.view.addSubview(controller.view)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        player.play()
        //self.setCompleted()
        
    }
    
    func playerDidFinishPlaying(note:NSNotification){
        print("finished")
        if let viewWithTag = self.parentContainer?.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        //self.setCompleted()
        self.book?.miss[index! + 1].state = 2
        if self.book?.story == true && (self.index! + 2) < (self.book?.miss.count)! {
            self.book?.miss[self.index! + 2].state = 1
        }
        self.Intro.text = "Nice! Wanna go again?"
       // self.parentContainer?.view.dismissViewControllerAnimated(true, completion: nil)
    }
    
	var book: Book?
    var index: Int?
	var isRightPage: Bool = false
	var shadowLayer: CAGradientLayer = CAGradientLayer()
	
	override var bounds: CGRect {
		didSet {
			shadowLayer.frame = bounds
		}
	}
	
	var image: UIImage? {
		didSet {
			let corners: UIRectCorner = isRightPage ? [UIRectCorner.topRight, UIRectCorner.bottomRight] : [UIRectCorner.topLeft, UIRectCorner.bottomLeft]
			imageView.image = image!.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(20, corners: corners)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupAntialiasing()
		initShadowLayer()
        self.button.isEnabled = true
        self.button.isUserInteractionEnabled = true
        self.lockedImg.isHidden = true
        self.completedImg.isHidden = true
	}
    
	
	func setupAntialiasing() {
		layer.allowsEdgeAntialiasing = true
		imageView.layer.allowsEdgeAntialiasing = true
	}
	
	func initShadowLayer() {
		let shadowLayer = CAGradientLayer()
		
		shadowLayer.frame = bounds
		shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
		shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
		
		self.imageView.layer.addSublayer(shadowLayer)
		self.shadowLayer = shadowLayer
	}
	
	func getRatioFromTransform() -> CGFloat {
		var ratio: CGFloat = 0
		
		let rotationY = CGFloat((layer.value(forKeyPath: "transform.rotation.y")! as AnyObject).floatValue!)
		if !isRightPage {
			let progress = -(1 - rotationY / CGFloat(CGFloat.pi/2))
			ratio = progress
		}
			
		else {
			let progress = 1 - rotationY / CGFloat(-CGFloat.pi/2)
			ratio = progress
		}
		
		return ratio
	}
	
	func updateShadowLayer(_ animated: Bool = false) {
		//var ratio: CGFloat = 0
		
		// Get ratio from transform. Check BookCollectionViewLayout for more details
		let inverseRatio = 1 - abs(getRatioFromTransform())
		
		if !animated {
			CATransaction.begin()
			CATransaction.setDisableActions(!animated)
		}
        if isRightPage {
            // Right page
            shadowLayer.colors = NSArray(objects:
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.45).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
                ) as? [UIColor]
            shadowLayer.locations = NSArray(objects:
                NSNumber(value: 0.00),
                                            NSNumber(value: 0.02),
                                            NSNumber(value: 1.00)
                ) as? [NSNumber]
        } else {
            // Left page
            shadowLayer.colors = NSArray(objects:
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.30).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.50).cgColor,
                                         UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor
                ) as? [UIColor]
            shadowLayer.locations = NSArray(objects:
                NSNumber(value: 0.00),
                                            NSNumber(value: 0.50),
                                            NSNumber(value: 0.98),
                                            NSNumber(value: 1.00)
                ) as? [NSNumber]
        }
        if !animated {
			CATransaction.commit()
		}
	}
 
     override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        //1
        if layoutAttributes.indexPath.item % 2 == 0 {
            //2
            layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            isRightPage = true
        } else { //3
            //4
            layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            isRightPage = false
        }
        //5
        self.updateShadowLayer()
     }
}
