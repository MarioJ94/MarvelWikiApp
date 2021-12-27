//
//  SpinnerCollectionViewFooter.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation
import UIKit

final class SpinnerCollectionViewFooter : UICollectionReusableView {
    private let spinner: UIActivityIndicatorView = {
        let spinn = UIActivityIndicatorView()
        spinn.style = .medium
        spinn.startAnimating()
        return spinn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureViews()
    }
    
    private func configureViews() {
        self.addSubview(self.spinner)
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.spinner.topAnchor.constraint(equalTo: self.topAnchor),
            self.spinner.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.spinner.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.spinner.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func setSpinnerColor(color: UIColor) {
        self.spinner.color = color
    }
}
