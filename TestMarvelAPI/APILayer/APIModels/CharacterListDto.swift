//
//  CharacterListDto.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation

struct CharacterListDto: Codable { // CharacterDataWrapper
    let code: Int?
    let status: String?
    let copyright: String?
    let attributionText: String?
    let attributionHTML: String?
    let data: CharacterListContainerDto?
    let etag: String?
}
