//
//  CharacterDetailsAppearancesButton.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 7/1/22.
//

import Foundation
import UIKit

final class CharacterDetailsAppearancesButton : UIView {
    
    private let titleLabel : UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.font = UIFont.systemFont(ofSize: 12, weight: .light)
        v.minimumScaleFactor = 0.8
        return v
    }()
    
    private let numberLabel : UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.font = UIFont.systemFont(ofSize: 26)
        v.minimumScaleFactor = 0.8
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureEverything()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureEverything()
    }
    
    private var selectedColorForBackground = UIColor.lightGray
    private var unselectedColorForBackground = UIColor.gray

    private let vMargins : CGFloat = 12
    private let hMargins : CGFloat = 22
    private let vDistance : CGFloat = 2
    private let stack : UIStackView = {
        let stack = UIStackView()
        return stack
    }()
    
    private func configureEverything() {
        self.clipsToBounds = true
        
        self.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = vDistance
        stack.axis = .vertical
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: vMargins),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: hMargins).withPriority(.defaultLow),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -hMargins).withPriority(.defaultLow),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -vMargins),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        stack.addArrangedSubview(titleLabel)
        titleLabel.text = "Title"
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        stack.addArrangedSubview(numberLabel)
        numberLabel.text = "0"
        numberLabel.setContentHuggingPriority(.required, for: .horizontal)
        numberLabel.setContentHuggingPriority(.required, for: .vertical)
        
        self.backgroundColor = self.unselectedColorForBackground
    }
    
    func setTitleText(text: String) {
        self.titleLabel.text = text
    }
    
    func setTitleTextColor(color: UIColor) {
        self.titleLabel.textColor = color
    }
    
    func setTitleFont(titleLabelFont: UIFont) {
        self.titleLabel.font = titleLabelFont
    }
    
    func setNumberText(text: String) {
        self.numberLabel.text = text
    }
    
    func setNumberTextColor(color: UIColor) {
        self.numberLabel.textColor = color
    }
    
    func setNumberFont(numberLabelFont: UIFont) {
        self.numberLabel.font = numberLabelFont
    }
    
    func setBackgroundColors(selected: UIColor, unselected: UIColor) {
        let wasUnselected = self.backgroundColor == self.unselectedColorForBackground
        self.selectedColorForBackground = selected
        self.unselectedColorForBackground = unselected
        let colorToUse = wasUnselected ? unselected : selected
        self.backgroundColor = colorToUse
    }
    
    func markSelected() {
        self.backgroundColor = self.selectedColorForBackground
    }
    
    func markUnselected() {
        self.backgroundColor = self.unselectedColorForBackground
    }
    
    func configureTap(target: Any?, action: Selector?) {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer (target: target, action: action)
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
}
