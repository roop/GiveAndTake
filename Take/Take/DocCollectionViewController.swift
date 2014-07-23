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

    init(documentsManager: DocumentsManager) {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = documentsManager
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
        view.dataSource = _documentsManager
        self.view = view
    }
}

class DocCollectionViewCell: UICollectionViewCell {
    var docURL: NSURL? {
        didSet {
            if let docURL = self.docURL {
                _nameLabel.text = ""
                _timestampLabel.text = ""
                var localizedName: AnyObject?, modifiedDate: AnyObject?
                var error: NSError?
                docURL.getResourceValue(&localizedName, forKey: NSURLLocalizedNameKey, error: &error)
                if (error != nil) { return }
                docURL.getResourceValue(&modifiedDate, forKey: NSURLAttributeModificationDateKey, error: &error)
                if (error != nil) { return }
                _nameLabel.text = localizedName as NSString
                _timestampLabel.text = _timestampFormatter.stringFromDate(modifiedDate as NSDate)
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
