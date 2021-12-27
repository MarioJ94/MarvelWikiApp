//
//  CustomGradientView.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 5/1/22.
//

import Foundation
import UIKit

final class CustomGradientView: UIView {
    private var startColor : UIColor = .clear
    private var endColor : UIColor = .clear

    private var gradient : CAGradientLayer? {
        return self.layer as? CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialzeViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialzeViews()
    }

    private func initialzeViews() {
        gradient?.frame = self.bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradient?.frame = self.bounds
    }

    func setStartPointColor(color: UIColor) {
        self.startColor = color
        self.updateColors()
    }

    func setEndPointColor(color: UIColor) {
        self.endColor = color
        self.updateColors()
    }

    private func updateColors() {
        self.gradient?.colors = [self.startColor.cgColor, self.endColor.cgColor]
    }

    func setStartPoint(point: CGPoint) {
        self.gradient?.startPoint = point
    }

    func setEndPoint(point: CGPoint) {
        self.gradient?.endPoint = point
    }
}
