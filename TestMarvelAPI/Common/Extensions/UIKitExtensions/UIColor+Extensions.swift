//
//  UIColor+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation
import UIKit

extension UIColor {
    static func adaptativeColor(lightMode: UIColor, darkMode: UIColor) -> UIColor {
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}

extension UIColor {
    static var defaultBackgroundColor : UIColor {
        return UIColor(named: "DefaultBackgroundColor") ?? .lightGray
    }
    
    static var defaultBackgroundSpinnerColor : UIColor {
        return UIColor(named: "DefaultBackgroundSpinnerColor") ?? .white
    }
    
    static var defaultNavBarColor : UIColor {
        return UIColor(named: "DefaultNavBarColor") ?? .white
    }
    
    static var defaultNavBarTextColor : UIColor {
        return UIColor(named: "DefaultNavBarTextColor") ?? .black
    }
}
