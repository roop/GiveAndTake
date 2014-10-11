//
//  ObservationHelper.swift
//  Take
//
//  Created by Roopesh Chander on 01/08/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import Foundation

// Usage:
// var observer1 = object.onChange("property") { change in
//                    doSomethingWithChangeDict(change)
//                }
// var observer2 = object.onNotification(NSMetadataQueryDidFinishGatheringNotification) {
//                    notification in
//                    doSomethingWithNotificationDict(notification.userInfo)
//                }
// // Keep a strong reference to the returned observer objects
// // as long as you want to observe said thingie.

extension NSObject {
    func onChange(keyPath: String, options: NSKeyValueObservingOptions,
        _ block: (change: [NSObject : AnyObject]!) -> ()) -> AnyObject {

        return KeyValueObserver(object: self, keyPath: keyPath, options: options, block: block)
            as AnyObject

    }

    func onChange(keyPath: String,
        _ block: (change: [NSObject : AnyObject]!) -> ()) -> AnyObject {

        return KeyValueObserver(object: self, keyPath: keyPath, options: nil, block: block)
            as AnyObject

    }

    func onNotification(name: String, _ block: ((NSNotification!) -> ())) -> AnyObject {

        return NotificationObserver(object: self, name: name, queue: NSOperationQueue.currentQueue(), block: block)
            as AnyObject

    }
}

class KeyValueObserver: NSObject {
    weak var _object: NSObject?
    var _keyPath: String
    var _block: (change: [NSObject : AnyObject]!) -> ()

    init(object: NSObject, keyPath: String, options: NSKeyValueObservingOptions,
        block: (change: [NSObject : AnyObject]!) -> ()) {

        _object = object
        _keyPath = keyPath
        _block = block
        super.init()
        object.addObserver(self, forKeyPath: keyPath, options: options, context: nil)

    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {

        assert(keyPath == _keyPath)
        _block(change: change)

    }

    deinit {
        _object?.removeObserver(self, forKeyPath: _keyPath, context: nil)
    }
}

class NotificationObserver: NSObject {
    var _observerObject: AnyObject?

    init(object: NSObject, name: String!, queue: NSOperationQueue!,
        block: ((NSNotification!) -> ())) {

        super.init()
        _observerObject = NSNotificationCenter.defaultCenter().addObserverForName(name, object: object,
            queue: queue, usingBlock: block)
    }

    deinit {
        if let observer: AnyObject = _observerObject {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
}
