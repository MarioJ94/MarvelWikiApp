//
//  AppearancesList.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 8/1/22.
//

import Foundation
import UIKit

final class AppearancesList : UIView {
    private let stack : UIStackView = {
        let stackV = UIStackView()
        return stackV
    }()
    
    weak var touchDelegate : AppearanceItemInteractionDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initializeViews()
    }
    
    private var itemsTextColorForCompleteLink = UIColor.white
    private var itemsTextColorForIncompleteLink = UIColor.white
    
    private func initializeViews() {
        self.stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 15
        stack.axis = .vertical
        self.clipsToBounds = true
        stack.clipsToBounds = true
        self.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    func setList(appearances: [AppearanceRef]) {
        self.stack.arrangedSubviews.forEach {
            self.stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for appearance in appearances {
            let item = AppearanceListItem()
            item.setAppearanceRef(apperanceInfo: appearance)
            item.setDelegate(touchDelegate: self.touchDelegate)
            item.updateColors(completeLink: self.itemsTextColorForCompleteLink, incompleteLink: self.itemsTextColorForIncompleteLink)
            item.translatesAutoresizingMaskIntoConstraints = false
            self.stack.addArrangedSubview(item)
            NSLayoutConstraint.activate([
                item.widthAnchor.constraint(equalTo: self.stack.widthAnchor),
                item.trailingAnchor.constraint(equalTo: self.stack.trailingAnchor)
            ])
        }
    }
    
    func setDelegate(touchDelegate: AppearanceItemInteractionDelegate?) {
        self.touchDelegate = touchDelegate
    }
    
    func setItemsColors(completeLink: UIColor, incompleteLink: UIColor) {
        self.itemsTextColorForCompleteLink = completeLink
        self.itemsTextColorForIncompleteLink = incompleteLink
        let items = stack.arrangedSubviews.compactMap({ $0 as? AppearanceListItem })
        for view in items {
            view.updateColors(completeLink: completeLink, incompleteLink: incompleteLink)
        }
    }
}
