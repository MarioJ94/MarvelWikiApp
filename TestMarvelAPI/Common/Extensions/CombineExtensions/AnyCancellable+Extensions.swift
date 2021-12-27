//
//  AnyCancellable+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation
import Combine

extension AnyCancellable {
    func store(in dictionary: inout [String:AnyCancellable], forKey key: String) {
        dictionary[key] = self
    }
    
    func store(in dictionary: inout [Int:AnyCancellable], forKey key: Int) {
        dictionary[key] = self
    }
}
