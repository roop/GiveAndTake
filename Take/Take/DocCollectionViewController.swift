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

    override func loadView() {
        var flowLayout: UICollectionViewFlowLayout = {
            var layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .Vertical
            layout.itemSize = CGSize(width: 100, height: 180)
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

                var localizedName: AnyObject?, modifiedDate: AnyObject?
                docURL.getResourceValue(&localizedName, forKey: NSURLLocalizedNameKey, error: nil)
                docURL.getResourceValue(&modifiedDate, forKey: NSURLAttributeModificationDateKey, error: nil)

                var subtitle = ""
                var isUbiquitous: AnyObject?
                docURL.getResourceValue(&isUbiquitous, forKey: NSURLIsUbiquitousItemKey, error: nil)
                if (isUbiquitous) {
                    var isUploading: AnyObject?, isDownloading: AnyObject?
                    docURL.getResourceValue(&isUploading, forKey: NSURLUbiquitousItemIsUploadingKey, error: nil)
                    docURL.getResourceValue(&isDownloading, forKey: NSURLUbiquitousItemIsDownloadingKey, error: nil)
                    if (isDownloading as NSNumber).boolValue {
                        subtitle = "Downloading"
                    } else if (isUploading as NSNumber).boolValue {
                        subtitle = "Uploading"
                    } else {
                        subtitle = _timestampFormatter.stringFromDate(modifiedDate as NSDate)
                    }
                } else {
                    subtitle = _timestampFormatter.stringFromDate(modifiedDate as NSDate)
                }

                _nameLabel.text = localizedName as NSString
                _timestampLabel.text = subtitle

            }
        }
    }

    var _nameLabel: UILabel = DocCollectionViewCell.createWhiteCenteredLabel()
    var _timestampLabel: UILabel = DocCollectionViewCell.createWhiteCenteredLabel()
    var _thumbnailContainer = UIView()
    var _thumbnailPlaceholder = UIView()

    lazy var _timestampFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeStyle = .NoStyle
        f.dateStyle = .MediumStyle
        return f
        }()

    init(frame: CGRect) {
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

    class func createWhiteCenteredLabel() -> UILabel {
        var label = UILabel()
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        return label
    }
}
