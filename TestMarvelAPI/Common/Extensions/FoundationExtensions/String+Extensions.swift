//
//  String+Extensions.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation

extension String {
    func appendPathExtension(ext: String) -> String {
        let nsPath = self as NSString
        let result = nsPath.appendingPathExtension(ext) ?? ""
        return result
    }
}
