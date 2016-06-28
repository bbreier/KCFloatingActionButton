//
//  KCFABManager.swift
//  KCFloatingActionButton-Sample
//
//  Created by LeeSunhyoup on 2015. 10. 13..
//  Copyright © 2015년 kciter. All rights reserved.
//

import UIKit

/**
 KCFloatingActionButton dependent on UIWindow.
 */
public class KCFABManager: NSObject {
    struct StaticInstance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: KCFABManager?
    }
    
    public class func defaultInstance() -> KCFABManager {
        dispatch_once(&StaticInstance.dispatchToken) {
            StaticInstance.instance = KCFABManager()
        }
        return StaticInstance.instance!
    }
    
    var _fabWindow: KCFABWindow? = nil
    var fabWindow: KCFABWindow {
        get {
            if _fabWindow == nil {
                _fabWindow = KCFABWindow(frame: UIScreen.mainScreen().bounds)
                _fabWindow?.rootViewController = fabController
            }
            return _fabWindow!
        }
    }
    
    var _fabController: KCFABViewController? = nil
    var fabController: KCFABViewController {
        get {
            if _fabController == nil {
                _fabController = KCFABViewController()
            }
            return _fabController!
        }
    }
    
    var contextualButtonHidden: Bool = false
    
    public func getButton() -> KCFloatingActionButton {
        return fabController.fab
    }
    
    public func getContextualButton() -> KCFloatingActionButton {
        return fabController.contextualButton
    }
    
    public func show(animated: Bool = true) {
        if animated == true {
            fabWindow.hidden = false
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.fabWindow.alpha = 1
            })
        } else {
            fabWindow.hidden = false
        }
    }
    
    public func hide(animated: Bool = true) {
        if animated == true {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.fabWindow.alpha = 0
                }, completion: { finished in
                    self.fabWindow.hidden = true
            })
        } else {
            fabWindow.hidden = true
        }
    }
    
    public func toggle(animated: Bool = true) {
        if fabWindow.hidden == false {
            self.hide(animated)
        } else {
            self.show(animated)
        }
    }
    
    public func hideContextualButton(animated: Bool = true) {
        if contextualButtonHidden == false {
            if animated == true {
                UIView.animateWithDuration(0.7, delay: 0,
                                           usingSpringWithDamping: 0.4,
                                           initialSpringVelocity: 0.8,
                                           options: [.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
                                            self.fabController.contextualButton.center.y += 100
                    }, completion:nil)
            } else {
                self.fabController.contextualButton.center.y += 100
            }
            contextualButtonHidden = true
        }
    }
    
    public func showContextualButton(animated: Bool = true) {
        if contextualButtonHidden == true {
            if animated == true {
                UIView.animateWithDuration(0.7, delay: 0,
                                           usingSpringWithDamping: 0.4,
                                           initialSpringVelocity: 0.8,
                                           options: [.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
                                            self.fabController.contextualButton.center.y -= 100
                    }, completion:nil)
            } else {
                self.fabController.contextualButton.center.y -= 100
            }
            contextualButtonHidden = false
        }
    }
    
    public func toggleContextualButton(animated: Bool = true) {
        if contextualButtonHidden == true {
            self.showContextualButton(animated)
        } else {
            self.hideContextualButton(animated)
        }
    }
    
    public func isHidden() -> Bool {
        return fabWindow.hidden
    }
}