//
//  TextEditController.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class TextEditorViewController: UIViewController {

    weak var _documentsManager: DocumentsManager!
    var _document: TextDocument? {
        didSet {
            if (self._view != nil) {
                if let document = self._document {
                    if (!(self._view!.text as NSString).isEqualToString(document.textContents)) {
                        self._view!.text = document.textContents
                    }
                } else {
                    self._view!.text = ""
                }
            }
        }
    }

    var _title: NSMutableString = ""
    var _view: UITextView?

    init(documentsManager: DocumentsManager, documentURL: NSURL? = nil) {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = documentsManager
        if (documentURL) {
            var document = TextDocument(fileURL: documentURL)
            document.openWithCompletionHandler( { (success: Bool) in
                if (success) {
                    self._document = document
                    var title = document.localizedName
                    self._title = title.mutableCopy() as NSMutableString
                    self.navigationItem.title = title
                }
                })
        }
    }

    override func loadView() {
        self.navigationItem.title = "Untitled"
        _view = {
                    let v = UITextView()
                    v.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                    v.delegate = self
                    if (self._document) {
                        v.text = self._document!.textContents
                    } else {
                        v.text = ""
                    }
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
                var textContents = (textView.text as NSString).stringByReplacingCharactersInRange(
                    range, withString: text)
                _documentsManager.createDocument(name: _title,
                    textContents: textContents,
                    completionHandler: { (document: TextDocument?) in
                        if (document != nil && self != nil && self._document == nil) {
                            self._document = document
                            println("Created")
                        }
                    })
            }

            return true
    }
}

extension TextEditorViewController {
    override func viewWillDisappear(animated: Bool) {
        if (self._document == nil) {
            if (_title.length > 0) {
                _documentsManager.createDocument(name: _title,
                    textContents: _title,
                    completionHandler: nil)
            }
            return
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