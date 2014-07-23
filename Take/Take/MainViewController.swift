//
//  MainViewController.swift
//  Take
//
//  Created by Roopesh Chander on 15/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    var _documentsManager: DocumentsManager!

    init() {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = DocumentsManager()

        self.navigationItem.title = "Take"
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .Add,
                target: self, action: "addButtonTapped:")
        ]
    }

    override func loadView() {
        var view = UIView()
        self.view = view

        var docCollectionVC = DocCollectionViewController(documentsManager: _documentsManager)
        self.addChildViewController(docCollectionVC)
        view.addSubviewsWithConstraints(
            (docCollectionVC.view, [ .FillIn(view) ])
        )
        docCollectionVC.didMoveToParentViewController(self)
    }

    func addButtonTapped(sender: UIBarButtonItem!) {
        self.navigationController.pushViewController(
            TextEditorViewController(documentsManager: _documentsManager),
            animated: true)
    }
}
