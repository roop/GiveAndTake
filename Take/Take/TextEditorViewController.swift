//
//  TextEditController.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class TextEditorViewController: UIViewController {

    var _documentsManager: DocumentsManager!
    var _document: TextDocument?
    var _title: NSMutableString = ""
    var _view: UITextView?

    init(documentsManager: DocumentsManager) {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = documentsManager
    }

    override func loadView() {
        self.navigationItem.title = "Untitled"
        _view = {
                    let v = UITextView()
                    v.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                    v.delegate = self
                    return v
                }()
        self.view = _view! as UIView
    }
}

extension TextEditorViewController: UITextViewDelegate {
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange,
        replacementText text: String!) -> Bool {

            // If we've already created the document, nothing to do for now
            if let document = self._document {
                document.textContents.replaceCharactersInRange(range, withString: text)
                document.updateChangeCount(.Done)
                return true
            }

            var isDocumentTitleFinalized = false

            // If we've not created the document yet, and if the edit
            // involves the first line, update our figured-out title
            if (range.location <= _title.length) {
                var replacementText: NSString = text as NSString
                var posOfLF = replacementText.rangeOfString("\n").location
                if (posOfLF != NSNotFound) {
                    replacementText = replacementText.substringToIndex(posOfLF)
                    isDocumentTitleFinalized = true
                }
                _title.replaceCharactersInRange(range, withString: replacementText)
                self.navigationItem.title = _title.length > 0 ? _title : "Untitled"
            } else {
                isDocumentTitleFinalized = true
            }

            // Once the user types past the first line,
            // create the document
            if (isDocumentTitleFinalized) {
                var document = _documentsManager.createDocument(name: _title)
                document.textContents = (textView.text as NSString).mutableCopy() as NSMutableString
                document.textContents.replaceCharactersInRange(range, withString: text)
                document.saveToURL(document.fileURL, forSaveOperation: .ForCreating,
                    completionHandler: { (fileCreated: Bool) in
                        if (fileCreated && self != nil && self._document == nil) {
                            self._document = document
                        }
                    })
            }

            return true
    }
}

extension TextEditorViewController {
    override func viewWillDisappear(animated: Bool) {
        if (self._document == nil) {
            var document = _documentsManager.createDocument(name: _title)
            document.textContents = ""
            self._document = document
        }
        self._document!.closeWithCompletionHandler({ success in
            if (success) {
                println("Saved and closed")
            } else {
                println("Error while saving/closing")
            }
            })
    }
}