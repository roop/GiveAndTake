//
//  DocumentsManager.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class DocumentsManager: NSObject {

    weak var documentsListDisplayDelegate: DocumentsManagerListDisplayDelegate?

    var isiCloudAvailable: Bool {
        return _iCloudManager.isiCloudAvailable
    }
    var isiCloudUsageEnabled: Bool {
        didSet { /* TODO */ }
    }
    var isUsingUbiquitousContainer: Bool {
        return _isUsingUbiquitousContainer
    }

    // Private variables

    var _iCloudManager: ICloudManager!
    var _localRootURL: NSURL
    var _ubiquitousRootURL: NSURL?
    var _localDocumentsList: [NSURL] = []
    var _ubiquitousDocumentsQuery = NSMetadataQuery()
    var _isListingLocalDocuments = false
    var _isUsingUbiquitousContainer: Bool = false {
        didSet {
            if (_isUsingUbiquitousContainer != oldValue) {
                self.documentsListDisplayDelegate?.documentsListReset?()
            }
        }
    }

    var _observers: [AnyObject] = []

    init(isiCloudUsageEnabled: Bool) {
        self.isiCloudUsageEnabled = isiCloudUsageEnabled

        // Init local documents

        _localRootURL = NSFileManager.defaultManager().URLsForDirectory(
            NSSearchPathDirectory.DocumentDirectory,
            inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as NSURL

        super.init()

        _isListingLocalDocuments = true
        listLocalDocumentsInBackgroundQueue(completion: { [weak self] documents in
                if let strongSelf = self {
                    assert(strongSelf._localDocumentsList.count == 0)
                    if let documents = documents {
                        strongSelf._localDocumentsList = documents
                    }
                    strongSelf._isListingLocalDocuments = false
                    if (!strongSelf.isiCloudUsageEnabled || !strongSelf._iCloudManager.isLoggedIntoiCloud) {
                        if (documents != nil && documents!.count > 0) {
                            var range = NSRange(location: 0, length: documents!.count)
                            strongSelf.documentsListDisplayDelegate?.documentsAddedAtIndexes?(
                                NSIndexSet(indexesInRange: range))
                        }
                    }
                }
            })

        // Init iCloud documents

        _iCloudManager = ICloudManager(delegate: self)
        if (_iCloudManager.isiCloudAvailable) {
            gotAccessToUbiquityContainer()
        }

    }

    func documentURLCount() -> Int {
        var i = (self.isUsingUbiquitousContainer ?
                    self.ubiquitousDocumentURLCount() :
                    self.localDocumentURLCount() )
        return i
    }

    func documentURLatIndex(i: Int) -> NSURL {
        return (self.isUsingUbiquitousContainer ?
                    self.ubiquitousDocumentURLatIndex(i) :
                    self.localDocumentURLatIndex(i) )
    }

}

// Local documents

extension DocumentsManager {

    func localDocumentURLCount() -> Int {
        return _localDocumentsList.count
    }

    func localDocumentURLatIndex(i: Int) -> NSURL {
        return _localDocumentsList[i]
    }

    func listLocalDocumentsInBackgroundQueue(#completion: (documents: [NSURL]?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            if let strongSelf = self {
                var error: NSError?
                let documents = NSFileManager.defaultManager().contentsOfDirectoryAtURL(strongSelf._localRootURL,
                    includingPropertiesForKeys: [ NSURLLocalizedNameKey, NSURLAttributeModificationDateKey ],
                    options: nil, error: &error)?.sorted( { (url1, url2) -> Bool in
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
                dispatch_async(dispatch_get_main_queue()) {
                    completion(documents: (error == nil) ? (documents as [NSURL]) : (nil))
                }
            }
        }
    }
}

// iCloud documents

extension DocumentsManager {

    func ubiquitousDocumentURLCount() -> Int {
        return _ubiquitousDocumentsQuery.resultCount
    }

    func ubiquitousDocumentURLatIndex(i: Int) -> NSURL {
        let mdItem: NSMetadataItem = _ubiquitousDocumentsQuery.resultAtIndex(i) as NSMetadataItem
        return mdItem.valueForAttribute(NSMetadataItemURLKey) as NSURL
    }

    func startUsingiCloud() {

        assert(_iCloudManager.isLoggedIntoiCloud)
        assert(_iCloudManager.ubiquityContainerURL != nil)

        // Find the root URL

        _ubiquitousRootURL = _iCloudManager.ubiquityContainerURL!.URLByAppendingPathComponent(
            "Documents",
            isDirectory: true)

        // Start a query

        var query = _ubiquitousDocumentsQuery
        if (!query.started) {
            query.searchScopes = [ NSMetadataQueryUbiquitousDocumentsScope ]
            query.predicate = NSPredicate(format: "%K LIKE '*'", argumentArray: [ NSMetadataItemFSNameKey ])

            _observers += [query.onChange("results") {
                [weak self] change in
                if let strongSelf = self {
                    if let indexes: AnyObject = change[NSKeyValueChangeIndexesKey] {
                        let indexes = change[NSKeyValueChangeIndexesKey] as NSMutableIndexSet
                        // Comments above observeValueForKeyPath() says:
                        // The change dictionary always contains an NSKeyValueChangeKindKey entry whose value
                        // is an NSNumber wrapping an NSKeyValueChange (use -[NSNumber unsignedIntegerValue]).
                        let kindOfChangeUInt = UInt((change[ NSKeyValueChangeKindKey ] as NSNumber).unsignedIntegerValue)
                        if let kindOfChange = NSKeyValueChange(rawValue: kindOfChangeUInt) {
                            switch kindOfChange {
                            case .Insertion:
                                strongSelf.documentsListDisplayDelegate?.documentsAddedAtIndexes?(indexes)
                            case .Removal:
                                strongSelf.documentsListDisplayDelegate?.documentsRemovedAtIndexes?(indexes)
                            case .Replacement:
                                strongSelf.documentsListDisplayDelegate?.documentsChangedAtIndexes?(indexes)
                            default:
                                break // Nothing to do
                            }
                        }
                    }
                }
            }] // End of query.onChange()

            // Start the query in the next run loop, in order to ensure that
            // documentsListReset() is called before any query results KVO fires.
            dispatch_async(dispatch_get_main_queue()) {
                let ok = self._ubiquitousDocumentsQuery.startQuery()
                if (!ok) {
                    println("Error starting NSMetaDataQuery")
                } else {
                    println("Started NSMetaDataQuery")
                }
            }
        }

        // Switch to the iCloud container

        self._isUsingUbiquitousContainer = true // Will cause documentsListReset() to be called

    }
}

extension DocumentsManager: iCloudManagerDelegate {

    func gotAccessToUbiquityContainer() {
        assert(_iCloudManager.isLoggedIntoiCloud)
        assert(_iCloudManager.ubiquityContainerURL != nil)
        if (self.isiCloudUsageEnabled) {
            startUsingiCloud()
        }
    }

    // TODO
    func loggedIntoiCloud() { NSLog("Logged into iCloud") }
    func loggedOutOfiCloud() { NSLog("Logged out of iCloud") }
    func iCloudUserChanged() { NSLog("iCloud user changed") }

}

// Creating a document

extension DocumentsManager {
    func createDocument(#name: NSString, textContents: NSString,
        completionHandler: ((TextDocument?) -> Void)?) {
        let isUsingUbiquitousContainer = self.isUsingUbiquitousContainer
        let rootURL: NSURL = (isUsingUbiquitousContainer ? _ubiquitousRootURL! : _localRootURL)
        let fileName = name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)?
                           .stringByAppendingPathExtension("txt")
        if (fileName == nil) { return; }
        let url = NSURL(string: fileName!, relativeToURL: rootURL)
        if (url == nil) { return; }
        if let document = TextDocument(fileURL: url!) {
            document.textContents = textContents.mutableCopy() as NSMutableString
            document.saveToURL(document.fileURL, forSaveOperation: .ForCreating,
                completionHandler: { [weak self] (fileCreated: Bool) in
                    if (fileCreated) {
                        if let strongSelf = self {
                            if (isUsingUbiquitousContainer) {
                                // Nothing to do. The NSMetaDataQuery will update automatically.
                            } else {
                                strongSelf._localDocumentsList.insert(url!, atIndex: 0)
                                strongSelf.documentsListDisplayDelegate?.documentsAddedAtIndexes?(NSIndexSet(index: 0))
                            }
                        }
                        completionHandler?(document)
                    } else {
                        completionHandler?(nil)
                    }
            })
        }
    }
}

@objc protocol DocumentsManagerListDisplayDelegate {
    optional func documentsAddedAtIndexes(indexes: NSIndexSet)
    optional func documentsRemovedAtIndexes(indexes: NSIndexSet)
    optional func documentsChangedAtIndexes(indexes: NSIndexSet)
    optional func documentsListReset()
}