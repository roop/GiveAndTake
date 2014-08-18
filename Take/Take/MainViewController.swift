//
//  MainViewController.swift
//  Take
//
//  Created by Roopesh Chander on 15/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController {
    var _documentsManager: DocumentsManager!

    override init() {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = DocumentsManager(isiCloudUsageEnabled: true)

        self.navigationItem.title = "Take"
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .Add,
                target: self, action: "addButtonTapped:"),
            UIBarButtonItem(barButtonSystemItem: .Organize,
                target: self, action: "documentPickerButtonTapped:")
        ]
    }

    required init(coder: NSCoder) {
        // Explicitly disallow initing from an archive
        fatalError("Object of type MainViewController cannot be initialized with an NSCoder")
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

    func documentPickerButtonTapped(sender: UIBarButtonItem!) {
        var documentUTIs: NSArray = [ kUTTypePlainText as NSString ]
        var documentPickerVC = UIDocumentPickerViewController(documentTypes: documentUTIs, inMode: .Open)
        documentPickerVC.delegate = self
        self.presentViewController(documentPickerVC, animated: true, completion: nil)
    }
}

extension MainViewController: UIDocumentPickerDelegate {
    func documentPicker(controller: UIDocumentPickerViewController!, didPickDocumentAtURL url: NSURL!) {
        // Show the text editor in the next run loop, so that the document picker
        // disappears first before the text editor appears.
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            if let strongSelf = self {
                var textEditorVC = TextEditorViewController(documentURL: url)
                strongSelf.navigationController.pushViewController(textEditorVC, animated: true)
            }
        }
    }

    func documentPickerWasCancelled(controller: UIDocumentPickerViewController!) {
        println("No document picked")
    }
}