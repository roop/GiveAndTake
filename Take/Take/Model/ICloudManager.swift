//
//  ICloudManager.swift
//  Take
//
//  Created by Roopesh Chander on 17/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class ICloudManager {

    // Private properties

    weak var _delegate: iCloudManagerDelegate!

    var _ubiquityIdentityToken: AnyObject? = nil {
        didSet {
            switch (oldValue, _ubiquityIdentityToken) {
            case (nil, nil):
                return
            case (nil, let _):
                _delegate?.loggedIntoiCloud?()
                self.getUbiquityContainerURLInBackgroundQueue()
            case (let _, nil):
                _ubiquityContainerURL = nil
                _delegate?.loggedOutOfiCloud?()
            case let (_, _):
                if (oldValue != nil && oldValue!.isEqual(_ubiquityIdentityToken)) {
                    return
                } else {
                    _ubiquityContainerURL = nil
                    self.getUbiquityContainerURLInBackgroundQueue()
                    _delegate?.iCloudUserChanged?()
                }
            }
        }
    }

    var _ubiquityContainerURL: NSURL? = nil {
        didSet {
            switch (oldValue, _ubiquityContainerURL) {
            case (nil, nil):
                return
            case (nil, let _):
                _delegate?.gotAccessToUbiquityContainer?()
            case (let _, nil):
                return
            default:
                return
            }
        }
    }

    var _iCloudTokenNotificationObserver: AnyObject?

    // Public read-only properties

    var isLoggedIntoiCloud: Bool {
        if (_ubiquityIdentityToken != nil) { return true } else { return false }
    }

    var ubiquityContainerURL: NSURL? {
        return _ubiquityContainerURL
    }

    var isiCloudAvailable: Bool {
        return (isLoggedIntoiCloud && _ubiquityContainerURL != nil)
    }

    // Init and Deinit

    init(delegate: iCloudManagerDelegate) {
        _delegate = delegate
        _ubiquityIdentityToken = NSFileManager.defaultManager().ubiquityIdentityToken
        _iCloudTokenNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            NSUbiquityIdentityDidChangeNotification, object: nil,
            queue: NSOperationQueue.mainQueue(), { [weak self] _ in
                if let strongSelf = self {
                    strongSelf._ubiquityIdentityToken = NSFileManager.defaultManager().ubiquityIdentityToken
                }
            })
        if (_ubiquityIdentityToken != nil) {
            self.getUbiquityContainerURLInBackgroundQueue()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self._iCloudTokenNotificationObserver)
    }

    // Methods

    func getUbiquityContainerURLInBackgroundQueue() {
        if (_ubiquityIdentityToken != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // In background thread
                var url = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
                dispatch_async(dispatch_get_main_queue()) {
                    // In main thread
                    self._ubiquityContainerURL = url
                }
            }
        }
    }
}

@objc protocol iCloudManagerDelegate {
    optional func loggedIntoiCloud()
    optional func loggedOutOfiCloud()
    optional func iCloudUserChanged()
    optional func gotAccessToUbiquityContainer()
}