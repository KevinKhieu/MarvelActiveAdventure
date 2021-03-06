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

class BooksViewController: UICollectionViewController {
    
    var transition: BookOpeningTransition?
    //1
    var interactionController: UIPercentDrivenInteractiveTransition?
    //2
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var leaveDate = Date()
    
    // MARK: Gesture recognizer action
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            //1
            interactionController = UIPercentDrivenInteractiveTransition()
            //2
            if recognizer.scale >= 1 {
                //3
                if recognizer.view == collectionView {
                    //4
                    let book = self.selectedCell()?.book
                    //5
                    self.openBook(book: book)
                }
                //6
            } else {
                //7
                navigationController?.popViewController(animated: true)
            }
        case .changed:
            //8
            if transition!.isPush {
                //9
                let progress = min(max(abs((recognizer.scale - 1)) / 5, 0), 1)
                //10
                interactionController?.update(progress)
                //11
            } else {
                //12
                let progress = min(max(abs((1 - recognizer.scale)), 0), 1)
                //13
                interactionController?.update(progress)
            }
        case .ended:
            //14
            interactionController?.finish()
            //15
            interactionController = nil
        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks("Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    func appMovedToBackground() {
        print("App moved to background!")
        leaveDate = Date()
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Spiderman Needs Your Help!"
            content.body = "Let's help him save the city!"
            content.sound = UNNotificationSound.default()
            
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error) in
                print(error ?? "uh oh")
            }
            print("should have been added")
        } else {
            
            // Fallback on earlier versions
        }
        
    }
    
    func appMovedToForeground() {
        let second:TimeInterval = 1.0
        let minute:TimeInterval = 60.0 * 1.0
        var currDate = Date();
        var diff = Date(timeInterval: minute, since: leaveDate)
        if currDate > diff {
            // too long - new mission
            print("Curr Date > Diff")
            for i in 0...((books?[0].miss.count)! - 1) {
                if books?[0].miss[i].state == 2 {
                    continue
                } else if books?[0].miss[i].state == 0 {
                    books?[0].miss[i].state = 1
                    break
                } else if books?[0].miss[i].state == 1 {
                    break
                }
            }
        }
        //Your functions..
        //let end = Date();
        //print("Time to do something: \(end.timeIntervalSince(start)) seconds");
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        print("App moved to foreground!")
    }
    
    // func updateBooks() 
    
    // MARK: Helpers
    func selectedCell() -> BookCoverCell? {
        if let indexPath = collectionView?.indexPathForItem(at: CGPoint(x: collectionView!.contentOffset.x + collectionView!.bounds.width / 2, y: collectionView!.bounds.height / 2)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? BookCoverCell {
                return cell
            }
        }
        return nil
    }
	
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let books = books {
            return books.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "BookCoverCell", for: indexPath) as! BookCoverCell
        
        cell.book = books?[indexPath.row]
        
        return cell
    }
    
    func openBook(book: Book?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        vc.book = selectedCell()?.book
        //1
        vc.view.snapshotView(afterScreenUpdates: true)
        //2
        DispatchQueue.main.async(execute: { () -> Void in
            self.navigationController?.pushViewController(vc, animated: true)
            return
        })
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books?[indexPath.row]
        openBook(book: book)
    }
}

extension BooksViewController {
    func animationControllerForPresentController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 1
        let transition = BookOpeningTransition()
        // 2
        transition.isPush = true
        transition.interactionController = interactionController
        // 3
        self.transition = transition
        // 4
        return transition
    }
    
    func animationControllerForDismissController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
}





