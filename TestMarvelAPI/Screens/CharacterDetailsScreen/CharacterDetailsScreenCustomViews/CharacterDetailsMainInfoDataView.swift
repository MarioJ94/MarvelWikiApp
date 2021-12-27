//
//  CharacterDetailsMainInfoDataView.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 3/1/22.
//

import Foundation
import UIKit

final class CharacterDetailsMainInfoDataView : UIView {
    
    private let titleLabel : UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.numberOfLines = 0
        let size : CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            size = 25
        } else {
            size = 35
        }
        v.font = UIFont.boldSystemFont(ofSize: size)
        return v
    }()
    
    private let descriptionLabel : UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.numberOfLines = 0
        let size : CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            size = 18
        } else {
            size = 24
        }
        v.font = UIFont.systemFont(ofSize: size, weight: .light)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureEverything()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureEverything() {
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setTitleColor(titleColor: UIColor) {
        self.titleLabel.textColor = titleColor
    }
    
    func setDescription(desc: String) {
        descriptionLabel.text = desc
    }
    
    func setDescriptionColor(descColor: UIColor) {
        self.descriptionLabel.textColor = descColor
    }
}
