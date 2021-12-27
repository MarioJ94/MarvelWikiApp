//
//  UIViewController+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 9/1/22.
//

import Foundation
import UIKit

extension UIViewController {
    func add(_ child: UINavigationController, inContainerView containerView: UIView, withAutolayoutMatch: Bool = true) {
        addChild(child)
        child.willMove(toParent: self)
        containerView.addSubview(child.view)
        if withAutolayoutMatch {
            child.view.translatesAutoresizingMaskIntoConstraints = true
            child.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            child.view.frame = containerView.bounds
        }
        child.didMove(toParent: self)
    }
}
