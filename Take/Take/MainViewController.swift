//
//  MainViewController.swift
//  Take
//
//  Created by Roopesh Chander on 15/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = "Take"
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .Add,
                target: self, action: "addButtonTapped:")
        ]
    }

    override func loadView() {
        var view = UIView()
        self.view = view
    }

    func addButtonTapped(sender: UIBarButtonItem!) {
        println("Tapped")
    }
}
