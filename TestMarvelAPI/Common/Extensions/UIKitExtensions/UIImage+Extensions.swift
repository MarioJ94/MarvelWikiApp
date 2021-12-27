//
//  UIImage+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation
import UIKit

extension UIImage {
    static var characterImageLoadFallbackImage: UIImage? {
        return UIImage(named: "CharacterImageLoadErrorImage")
    }
}
