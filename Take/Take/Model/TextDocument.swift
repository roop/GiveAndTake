//
//  TextDocument.swift
//  Take
//
//  Created by Roopesh Chander on 19/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit
import MobileCoreServices

class TextDocument: UIDocument {
    var textContents: NSMutableString = ""
    weak var editorDelegate: TextDocumentEditorDelegate?

    override func loadFromContents(contents: AnyObject!, ofType typeName: String!, error outError: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        if UTTypeConformsTo(typeName as NSString, kUTTypePlainText) > 0 {
            self.textContents = NSMutableString(data: contents as NSData, encoding: NSUTF8StringEncoding)
            return true
        }
        return false
    }

    override func contentsForType(typeName: String!, error outError: AutoreleasingUnsafeMutablePointer<NSError?>) -> AnyObject! {
        if UTTypeConformsTo(typeName as NSString, kUTTypePlainText) > 0 {
            var data = textContents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            return data
        }
        return nil
    }

    override var fileType: String! {
        return kUTTypeUTF8PlainText as NSString
    }

    override func savingFileType() -> String! {
        return kUTTypePlainText as NSString
    }

    override func disableEditing() {
        self.editorDelegate?.disableEditing?()
    }

    override func enableEditing() {
        self.editorDelegate?.enableEditing?()
    }
}

@objc protocol TextDocumentEditorDelegate {
    optional func disableEditing()
    optional func enableEditing()
}