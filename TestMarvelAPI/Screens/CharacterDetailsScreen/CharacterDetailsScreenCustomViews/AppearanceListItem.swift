//
//  File.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 8/1/22.
//

import Foundation
import UIKit

protocol AppearanceItemInteractionDelegate : AnyObject {
    func didTap(appearanceInfo: AppearanceRef)
}

final class AppearanceListItem : UIView {
    private let label : UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        return v
    }()
    
    weak var touchDelegate : AppearanceItemInteractionDelegate?
    
    var appearanceRef : AppearanceRef?
    private var completeLinkColor = UIColor.white
    private var incompleteLinkColor = UIColor.systemGray2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedItem(sender:)))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        self.clipsToBounds = true
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    @objc
    private func tappedItem(sender: UITapGestureRecognizer) {
        guard let appearanceRef = appearanceRef else {
            return
        }
        touchDelegate?.didTap(appearanceInfo: appearanceRef)
    }

    func setAppearanceRef(apperanceInfo: AppearanceRef) {
        self.appearanceRef = apperanceInfo
        self.label.text = apperanceInfo.name
    }
    
    func updateAppearanceRef(appearanceInfo: AppearanceRef) {
        self.setAppearanceRef(apperanceInfo: appearanceInfo)
        self.adaptLabelColor()
    }
    
    func setDelegate(touchDelegate: AppearanceItemInteractionDelegate?) {
        self.touchDelegate = touchDelegate
    }
    
    func updateColors(completeLink: UIColor, incompleteLink: UIColor) {
        self.completeLinkColor = completeLink
        self.incompleteLinkColor = incompleteLink
        self.adaptLabelColor()
    }
    
    private func adaptLabelColor() {
        let colorToUse = self.appearanceRef?.url != nil ? self.completeLinkColor : self.incompleteLinkColor
        self.label.textColor = colorToUse
    }
}
