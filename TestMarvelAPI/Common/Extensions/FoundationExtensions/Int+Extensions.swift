//
//  Int+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 7/1/22.
//

import Foundation

extension Int {
    var asNSNumber: NSNumber {
        return NSNumber(integerLiteral: self)
    }
}
