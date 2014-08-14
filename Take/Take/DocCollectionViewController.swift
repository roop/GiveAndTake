//
//  DocCollectionViewController.swift
//  Take
//
//  Created by Roopesh Chander on 24/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class DocCollectionViewController: UIViewController {
    weak var _documentsManager: DocumentsManager!
    var _dataSource: DocCollectionViewDataSource!

    init(documentsManager: DocumentsManager) {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = documentsManager
        _documentsManager.documentsListDisplayDelegate = self
    }

    required init(coder: NSCoder) {
        // Explicitly disallow initing from an archive
        fatalError("Object of type DocCollectionViewController cannot be initialized with an NSCoder")
    }

    override func loadView() {
        var flowLayout: UICollectionViewFlowLayout = {
            var layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .Vertical
            layout.itemSize = CGSize(width: 120, height: 220)
            layout.minimumLineSpacing = 40
            layout.minimumInteritemSpacing = 40
            return layout
            }()
        var view = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        view.backgroundColor = UIColor.grayColor()
        view.registerClass(DocCollectionViewCell.self, forCellWithReuseIdentifier: "DocCollectionCell")
        _dataSource = DocCollectionViewDataSource(documentsManager: _documentsManager)
        view.dataSource = _dataSource
        view.delegate = self
        self.view = view
    }
}

extension DocCollectionViewController: DocumentsListDisplayDelegate {
    func documentsAddedAtIndexes(indexes: NSIndexSet) {
        var indexPaths: [NSIndexPath] = []
        indexes.enumerateIndexesUsingBlock { i, _ in
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        (self.view as UICollectionView).insertItemsAtIndexPaths(indexPaths)
    }

    func documentsChangedAtIndexes(indexes: NSIndexSet) {
        var indexPaths: [NSIndexPath] = []
        indexes.enumerateIndexesUsingBlock { i, _ in
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        (self.view as UICollectionView).reloadItemsAtIndexPaths(indexPaths)
    }

    func documentsListReset() {
        (self.view as UICollectionView).reloadData()
    }
}

extension DocCollectionViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        var documentURL = _documentsManager.documentURLatIndex(indexPath.item)
        var textEditorVC = TextEditorViewController(documentsManager: _documentsManager,
            documentURL: documentURL)
        self.navigationController.pushViewController(textEditorVC, animated: true)
    }
}

class DocCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    weak var _documentsManager: DocumentsManager!

    init(documentsManager: DocumentsManager) {
        super.init()
        _documentsManager = documentsManager
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection _: Int) -> Int {
        return _documentsManager.documentURLCount()
    }
    func collectionView(collectionView: UICollectionView!,
        cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("DocCollectionCell",
            forIndexPath: indexPath) as DocCollectionViewCell
        assert(indexPath.section == 0)
        cell.docURL = _documentsManager.documentURLatIndex(indexPath.item)
        return cell
    }
}

class DocCollectionViewCell: UICollectionViewCell {
    var docURL: NSURL? {
        didSet {
            if let docURL = self.docURL {

                _nameLabel.text = ""
                _timestampLabel.text = ""

                let docMetaData = docURL.promisedItemResourceValuesForKeys(
                    [   NSURLLocalizedNameKey,
                        NSURLContentModificationDateKey,
                        NSURLIsUbiquitousItemKey,
                        NSURLUbiquitousItemDownloadingStatusKey,
                        NSURLUbiquitousItemIsDownloadingKey,
                        NSURLUbiquitousItemIsUploadingKey
                    ], error: nil)

                let ubiquityStatus = DocumentUbiquityStatus(urlMetaData: docMetaData)

                var subtitle = ""
                if (ubiquityStatus.documentIsUbiquitous) {
                    if (ubiquityStatus.documentIsDownloading) {
                        subtitle = "Downloading"
                    } else if (ubiquityStatus.documentIsUploading) {
                        subtitle = "Uploading"
                    } else if (!ubiquityStatus.documentIsUpToDate) {
                        subtitle = "Tap to download"
                    }
                }
                if (subtitle.isEmpty) {
                    subtitle = _timestampFormatter.stringFromDate(docMetaData[NSURLContentModificationDateKey] as NSDate)
                }

                _nameLabel.text = docMetaData[NSURLLocalizedNameKey] as NSString
                _timestampLabel.text = subtitle

            }
        }
    }

    let _nameLabel: UILabel = DocCollectionViewCell.createWhiteCenteredLabel()
    let _timestampLabel: UILabel = DocCollectionViewCell.createWhiteCenteredLabel()
    let _thumbnailContainer = UIView()
    let _thumbnailPlaceholder = UIView()

    lazy var _timestampFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeStyle = .NoStyle
        f.dateStyle = .MediumStyle
        return f
        }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        _nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        _timestampLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        _thumbnailContainer.addSubviewsWithConstraints(
            (_thumbnailPlaceholder, [
                .Anchor(.Left, _thumbnailContainer.left(margin: 10)),
                .Anchor(.Right, _thumbnailContainer.right(margin: -10)),
                .Anchor(.Top, _thumbnailContainer.top(margin: 20)),
                .Anchor(.Bottom, _thumbnailContainer.bottom(margin: -20))
                ])
        )
        _thumbnailPlaceholder.backgroundColor = UIColor.whiteColor()
        self.addSubviewsWithConstraints(
            (_timestampLabel, [
                .FillHorizontallyIn(self),
                .Anchor(.Bottom, self.bottom())
                ]),
            (_nameLabel, [
                .FillHorizontallyIn(self),
                .Anchor(.Bottom, _timestampLabel.top())
                ]),
            (_thumbnailContainer, [
                .FillHorizontallyIn(self),
                .Anchor(.Top, self.top()),
                .Anchor(.Bottom, _nameLabel.top())
                ])
        )
    }

    required init(coder: NSCoder) {
        // Explicitly disallow initing from an archive
        fatalError("Object of type DocCollectionViewCell cannot be initialized with an NSCoder")
    }

    class func createWhiteCenteredLabel() -> UILabel {
        var label = UILabel()
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        return label
    }
}

struct DocumentUbiquityStatus {
    let documentIsUbiquitous: Bool
    let documentIsDownloading: Bool
    let documentIsUploading: Bool
    let documentIsUpToDate: Bool
    init(urlMetaData: [NSObject : AnyObject]) {
        documentIsUbiquitous = ((urlMetaData[NSURLIsUbiquitousItemKey] as? NSNumber ?? 0)  > 0)
        documentIsDownloading = ((urlMetaData[NSURLUbiquitousItemIsDownloadingKey] as? NSNumber ?? 0)  > 0)
        documentIsUploading = ((urlMetaData[NSURLUbiquitousItemIsUploadingKey] as? NSNumber ?? 0)  > 0)
        documentIsUpToDate = ((urlMetaData[NSURLUbiquitousItemDownloadingStatusKey] as? NSString)?
            .isEqualToString(NSURLUbiquitousItemDownloadingStatusCurrent)) ?? false
    }
}
