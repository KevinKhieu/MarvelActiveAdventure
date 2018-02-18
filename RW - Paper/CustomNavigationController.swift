//
//  CustomNavigationController.swift
//  RW - Paper
//
//  Created by Joachim  on 10/3/17.
//  Copyright © 2017 -. All rights reserved.
//

import UIKit
import UserNotifications
class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1
        delegate = self
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationWillResignActive, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
//    func appMovedToBackground() {
//        print("App moved to background!")
//        if #available(iOS 10.0, *) {
//            let content = UNMutableNotificationContent()
//            content.title = "Spiderman Needs Your Help!"
//            content.body = "Let's help him save the city!"
//            content.sound = UNNotificationSound.default()
//            
//            // Deliver the notification in five seconds.
//            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: false)
//            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
//            
//            // Schedule the notification.
//            let center = UNUserNotificationCenter.current()
//            center.add(request) { (error) in
//                print(error ?? "uh oh")
//            }
//            print("should have been added")
//        } else {
//            
//            // Fallback on earlier versions
//        }
//
//    }
//    
//    func appMovedToForeground() {
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        }
//        print("App moved to foreground!")
//    }
    
    //2
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            if let vc = fromVC as? BooksViewController {
                return vc.animationControllerForPresentController(vc: toVC)
            }
        }
        
        if operation == .pop {
            if let vc = toVC as? BooksViewController {
                return vc.animationControllerForDismissController(vc: vc)
            }
        }
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let animationController = animationController as? BookOpeningTransition {
            return animationController.interactionController
        }
        return nil
    }
}
