//
//  CharacterListContainerDto.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation

struct CharacterListContainerDto: Codable { // CharacterDataContainer
    let offset: Int?
    let limit: Int?
    let total: Int?
    let count: Int?
    let results: [CharacterDto]?
}
