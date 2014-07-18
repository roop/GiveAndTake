//
//  TextEditController.swift
//  Take
//
//  Created by Roopesh Chander on 18/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class TextEditorViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        var view = UITextView()
        self.view = view as UIView
        view.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
}
