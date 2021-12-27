//
//  ComicListDto.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation

struct ComicListDto: Codable {
    let available: Int?
    let returned: Int?
    let collectionURI: String?
    let items: [ComicSummaryDto]?
}
