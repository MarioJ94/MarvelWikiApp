//
//  PaginatedContentTotalResults.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

enum PaginatedContentTotalResults {
    case notFetched
    case fetched(number: Int)
    case totalChanged
}
