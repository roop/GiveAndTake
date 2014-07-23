//
//  DocumentsManager.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class DocumentsManager: NSObject {
    var _iCloudManager: ICloudManager!
    var _documentsRootURL: NSURL!
    var _localDocuments: [NSURL] = []

    init() {
        super.init()
        _iCloudManager = ICloudManager(delegate: self)
        if (_iCloudManager.isLoggedIntoiCloud && _iCloudManager.ubiquityContainerURL) {
            _documentsRootURL = NSURL(string: "Documents", relativeToURL: _iCloudManager.ubiquityContainerURL)
        } else {
            _documentsRootURL = NSFileManager.defaultManager().URLsForDirectory(
                NSSearchPathDirectory.DocumentDirectory,
                inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as? NSURL
        }
        self.startListingDocuments()
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

    func startListingDocuments() {
        // ls iCloud directory
        if (_iCloudManager.isLoggedIntoiCloud) {
            // TODO
        }

        // ls local directory
        var error: NSError?
        let documents = NSFileManager.defaultManager().contentsOfDirectoryAtURL(_documentsRootURL,
            includingPropertiesForKeys: [ NSURLLocalizedNameKey, NSURLAttributeModificationDateKey ],
            options: nil, error: &error).sorted( { (url1, url2) -> Bool in
                // Sort so we get most recently modified first
                var error1: NSError?, error2: NSError?
                var modifiedDate1: AnyObject?, modifiedDate2: AnyObject?
                url1.getResourceValue(&modifiedDate1, forKey: NSURLAttributeModificationDateKey, error: &error1)
                url2.getResourceValue(&modifiedDate2, forKey: NSURLAttributeModificationDateKey, error: &error2)
                if (error1 == nil && error2 == nil) {
                    var comparisonResult: NSComparisonResult = (modifiedDate1 as NSDate)
                        .compare(modifiedDate2 as NSDate)
                    return (comparisonResult == .OrderedDescending)
                }
                return true
                } )
        if (error == nil) {
            _localDocuments = documents as [NSURL]
        }
    }
}

extension DocumentsManager: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection _: Int) -> Int {
        return _localDocuments.count
    }
    func collectionView(collectionView: UICollectionView!,
            cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("DocCollectionCell",
            forIndexPath: indexPath) as DocCollectionViewCell
        assert(indexPath.section == 0)
        cell.docURL = _localDocuments[indexPath.item]
        return cell
    }
}