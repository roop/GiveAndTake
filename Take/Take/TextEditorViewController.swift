//
//  TextEditController.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class TextEditorViewController: UIViewController {

    weak var _documentsManager: DocumentsManager?
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
    var _isDownloadingDocument: Bool = false

    var _title: NSMutableString = ""
    var _view: UITextView?

    // Create a text editor to create a new document

    init(documentsManager: DocumentsManager) {
        super.init(nibName: nil, bundle: nil)
        _documentsManager = documentsManager
    }

    // Create a text editor to open an existing document

    init(documentURL: NSURL) {
        super.init(nibName: nil, bundle: nil)
        let urlMetaData = documentURL.promisedItemResourceValuesForKeys(
            [   NSURLIsUbiquitousItemKey,
                NSURLUbiquitousItemDownloadingStatusKey
            ], error: nil)
        let ubiquityStatus = DocumentUbiquityStatus(urlMetaData: urlMetaData)
        if (ubiquityStatus.documentIsUbiquitous && !ubiquityStatus.documentIsUpToDate) {
            _isDownloadingDocument = true
            NSFileManager.defaultManager().startDownloadingUbiquitousItemAtURL(documentURL, error: nil)
        }
        if let document = TextDocument(fileURL: documentURL) {
            document.openWithCompletionHandler( { (success: Bool) in
                if (success) {
                    self._isDownloadingDocument = false
                    self._view?.editable = true
                    self._document = document
                    document.editorDelegate = self
                    var title = document.localizedName
                    self._title = title.mutableCopy() as NSMutableString
                    self.navigationItem.title = title
                }
            })
        }
    }

    required init(coder: NSCoder) {
        // Explicitly disallow initing from an archive
        fatalError("Object of type TextEditorViewController cannot be initialized with an NSCoder")
    }

    override func loadView() {
        self.navigationItem.title = (_isDownloadingDocument ? "Downloading ..." : "Untitled")
        _view = {
                    let v = UITextView()
                    v.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                    v.delegate = self
                    if (self._document != nil) {
                        v.text = self._document!.textContents
                    } else {
                        v.text = ""
                    }
                    return v
                }()
        if (_isDownloadingDocument) {
            _view?.editable = false
        }
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
                let textContents = (textView.text as NSString).stringByReplacingCharactersInRange(
                    range, withString: text)
                _documentsManager?.createDocument(name: _title,
                    textContents: textContents,
                    completionHandler: { (document: TextDocument?) in
                        if (document != nil && self._document == nil) {
                            self._document = document
                            println("Created")
                        }
                    })
            }

            return true
    }
}

extension TextEditorViewController: TextDocumentEditorDelegate {
    func disableEditing() {
        if let view = _view {
            view.editable = false
        }
    }
    func enableEditing() {
        if let view = _view {
            view.editable = true
        }
    }
}

extension TextEditorViewController {
    override func viewWillDisappear(animated: Bool) {
        if (self._document == nil) {
            if (_title.length > 0) {
                _documentsManager?.createDocument(name: _title,
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