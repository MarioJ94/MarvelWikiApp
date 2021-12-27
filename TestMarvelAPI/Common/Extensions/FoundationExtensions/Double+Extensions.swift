//
//  Double+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 7/1/22.
//

import Foundation

extension Double {
    func rounded(withDecimals decimals: Int, rule: FloatingPointRoundingRule) -> Double {
        let divisor = pow(10.0, Double(decimals))
        return (self * divisor).rounded(rule) / divisor
    }
}
