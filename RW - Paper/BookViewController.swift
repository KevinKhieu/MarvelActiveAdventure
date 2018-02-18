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
import AVFoundation
import AVKit

//import CoreMotion

class BookViewController: UICollectionViewController {
    var stepsTaken:[Int] = []
//    let activityManager = CMMotionActivityManager()
//    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HIHIHIIHI")
        collectionView?.reloadData()
//        pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
//            if let pedData = pedometerData{
//                print("Steps:\(pedData.numberOfSteps)")
//            } else {
//                print("ERROR IN PEDOMETER")
//            }
//        })
    }
    
    
    var book: Book? {
        didSet {
            collectionView?.reloadData()
        }
    }
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let book = book {
            return book.numberOfPages() + 1
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "BookPageCell", for: indexPath) as! BookPageCell
        cell.parentContainer = self
        cell.book = self.book
        if indexPath.row % 2 == 0 {
            cell.running = true
        }
        cell.index = indexPath.row - 1
        if indexPath.row == 0 {
            // Cover page
            cell.hideStuff()
            cell.image = book?.coverImage()
        }
            
        else {
            // Page with index: indexPath.row - 1
            cell.setTitle(title: (book?.pageTitle(indexPath.row - 1))!)
            cell.setIntro(title: (book?.pageIntro(indexPath.row - 1))!)
            //cell.textLabel.text = "\(indexPath.row)"
            print ("HIHI")
            cell.image = book?.pageImage(indexPath.row - 1)
            if book?.pageState(indexPath.row - 1) == 0 {
                cell.setNotStarted()
            } else if book?.pageState(indexPath.row - 1) == 2 {
                cell.setCompleted()
            } else {
                cell.setActive()
            }
        }
        
        return cell
    }

}


