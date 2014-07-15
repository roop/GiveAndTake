//
//  AutoLayoutHelper.swift
//  TextDocs
//
//  Created by Roopesh Chander on 11/07/14.
//  Copyright (c) 2014 Roopesh Chander. All rights reserved.
//

import UIKit

enum LayoutInfo {
    case FillIn(UIView)
    case FillHorizontallyIn(UIView)
    case FillVerticallyIn(UIView)
    case CenterIn(UIView)
    case Anchor(NSLayoutAttribute, (ViewOrLayoutGuide, NSLayoutAttribute, Float))
}

enum ViewOrLayoutGuide {
    case View(UIView)
    case LayoutGuide(UILayoutSupport)
}

extension UIView {
    func top(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.View(self), .Top, margin)
    }

    func bottom(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.View(self), .Bottom, margin)
    }

    func left(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.View(self), .Left, margin)
    }

    func right(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.View(self), .Right, margin)
    }

    func centerX(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.View(self), .CenterX, margin)
    }

    func centerY(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.View(self), .CenterY, margin)
    }
}

extension UIViewController {
    func bottomOfTopLayoutGuide(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.LayoutGuide(self.topLayoutGuide), .Bottom, margin)
    }

    func topOfBottomLayoutGuide(margin: Float = 0) -> (ViewOrLayoutGuide, NSLayoutAttribute, Float) {
        return (ViewOrLayoutGuide.LayoutGuide(self.bottomLayoutGuide), .Top, margin)
    }
}

extension UIView {
    func addSubviewsWithConstraints(subviews: (UIView, Array<LayoutInfo>)...) -> Void {
        var currentSubviews: NSArray = self.subviews

        iteratingOverSubviews: for subviewDataTuple in subviews {

            let (subview, layoutInfoArray) = subviewDataTuple
            if (currentSubviews.containsObject(subview)) {
                continue iteratingOverSubviews
            }
            addSubview(subview)
            subview.setTranslatesAutoresizingMaskIntoConstraints(false)

            func bindLayoutAttributes(view1: UIView, view2: UIView, layoutAttributes: [NSLayoutAttribute]) {
                for attribute in layoutAttributes {
                    addConstraint(NSLayoutConstraint(item: view1, attribute: attribute, relatedBy: .Equal,
                        toItem: view2, attribute: attribute, multiplier: 1, constant: 0))
                }
            }

            for (layoutInfo: LayoutInfo) in layoutInfoArray {
                switch layoutInfo {
                case .FillIn(let view):
                    bindLayoutAttributes(subview, view, [.Top, .Right, .Bottom, .Left])
                case .FillHorizontallyIn(let view):
                    bindLayoutAttributes(subview, view, [.Left, .Right])
                case .FillVerticallyIn(let view):
                    bindLayoutAttributes(subview, view, [.Top, .Bottom])
                case .CenterIn(let view):
                    bindLayoutAttributes(subview, view, [.CenterX, .CenterY])
                case .Anchor(let attr1, (let viewOrLayoutGuide, let attr2, let margin)):
                    switch viewOrLayoutGuide {
                        case .View(let v):
                            addConstraint(NSLayoutConstraint(item: subview, attribute: attr1, relatedBy: .Equal,
                                toItem: v, attribute: attr2, multiplier: 1, constant: CGFloat(margin)))
                        case .LayoutGuide(let l):
                            addConstraint(NSLayoutConstraint(item: subview, attribute: attr1, relatedBy: .Equal,
                                toItem: l, attribute: attr2, multiplier: 1, constant: CGFloat(margin)))
                    }
                }
            } // end of for layoutInfo
        } // end of iteratingOverSubviews

    } // end of func addSubviewsWithConstraints
}
