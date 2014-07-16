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
            case (let _, nil):
                _delegate?.loggedOutOfiCloud?()
            case let (_, _):
                if (oldValue?.isEqual(_ubiquityIdentityToken)) {
                    return
                } else {
                    _delegate?.iCloudUserChanged?()
                }
            }
        }
    }

    var _iCloudTokenNotificationObserver: AnyObject?

    // Public read-only properties

    var isLoggedIntoiCloud: Bool {
        if (_ubiquityIdentityToken) { return true } else { return false }
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
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self._iCloudTokenNotificationObserver)
    }

}

@objc protocol iCloudManagerDelegate {
    @optional func loggedIntoiCloud()
    @optional func loggedOutOfiCloud()
    @optional func iCloudUserChanged()
}