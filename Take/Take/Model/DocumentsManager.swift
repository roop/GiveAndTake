//
//  DocumentsManager.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class DocumentsManager {
    var _iCloudManager: ICloudManager!
    var _documentsRootURL: NSURL!

    init() {
        _iCloudManager = ICloudManager(delegate: self)
        if (_iCloudManager.isLoggedIntoiCloud && _iCloudManager.ubiquityContainerURL) {
            _documentsRootURL = NSURL(string: "Documents", relativeToURL: _iCloudManager.ubiquityContainerURL)
        } else {
            _documentsRootURL = NSFileManager.defaultManager().URLsForDirectory(
                NSSearchPathDirectory.DocumentDirectory,
                inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as? NSURL
        }
    }
}

extension DocumentsManager: iCloudManagerDelegate {

    func gotAccessToUbiquityContainer() {
        assert(_iCloudManager.isLoggedIntoiCloud)
        assert(_iCloudManager.ubiquityContainerURL)
        _documentsRootURL = NSURL(string: "Documents", relativeToURL: _iCloudManager.ubiquityContainerURL)
    }

    // TODO
    func loggedIntoiCloud() { NSLog("Logged into iCloud") }
    func loggedOutOfiCloud() { NSLog("Logged out of iCloud") }
    func iCloudUserChanged() { NSLog("iCloud user changed") }

}

extension DocumentsManager {
    func createDocument(#name: NSString) -> TextDocument {
        var fileName = name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var url = NSURL(string: fileName, relativeToURL: _documentsRootURL)
        return TextDocument(fileURL: url)
    }
}