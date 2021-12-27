//
//  APIOperationError.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation

enum APIOperationError: Error {
    case decodingError(error: Error)
    case requestFailed
}
