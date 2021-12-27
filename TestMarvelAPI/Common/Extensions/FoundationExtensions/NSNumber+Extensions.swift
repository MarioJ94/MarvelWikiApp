//
//  NSNumber+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 7/1/22.
//

import Foundation

extension NSNumber {
    struct NumberAbbreviationDescriptor {
        enum NumberAbbreviationType : Equatable {
            case noSuffixNeeded(number: NSNumber)
            case withSuffix(number: NSNumber, suffix: String)
            case infinite
        }
        let type : NumberAbbreviationType
        let positive : Bool
    }
    
    func abbreviatedDescription(withMaxDecimals maxDecimals: Int) -> NumberAbbreviationDescriptor {
        var num = self.doubleValue
        let isPositive = num >= 0
        
        guard num != 0 else {
            return .init(type: .noSuffixNeeded(number: 0), positive: true)
        }
        
        num = fabs(num)
        
        let units:[String] = ["", "K","M","G","T","P","E", "Z", "Y"]
        let exp:Int = Int(log10(num) / 3 )
        
        guard exp < units.count else {
            return .init(type: .infinite, positive: isPositive)
        }
        let roundedNum : Double = ((10 * num / pow(1000.0,Double(exp))) / 10).rounded(withDecimals: maxDecimals, rule: .towardZero)
        let number = NSNumber(value: roundedNum)
        let unit = units[exp]
        if unit.isEmpty {
            return .init(type: .noSuffixNeeded(number: number), positive: isPositive)
        } else {
            return .init(type: .withSuffix(number: number, suffix: unit), positive: isPositive)
        }
    }
}
