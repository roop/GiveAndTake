//
//  MainViewController.swift
//  Take
//
//  Created by Roopesh Chander on 15/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    override func loadView() {
        var view = UIView()
        self.view = view

        var navigationBar = UINavigationBar()
        navigationBar.delegate = self
        var navigationItem = UINavigationItem(title: "Take")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .Plain,
            target: self, action: "openButtonTapped:")
        navigationBar.items = [ navigationItem ]

        view.addSubviewsWithConstraints(
            (navigationBar, [
                .FillHorizontallyIn(view),
                .Anchor(.Top, self.bottomOfTopLayoutGuide())
                ])
        )
    }

    func openButtonTapped(sender: UIBarButtonItem!) {
        println("Tapped")
    }
}

extension MainViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition {
        return .TopAttached
    }
}