//
//  EventListDto.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation

struct EventListDto: Codable {
    let available: Int?
    let returned: Int?
    let collectionURI: String?
    let items: [EventSummaryDto]?
}
