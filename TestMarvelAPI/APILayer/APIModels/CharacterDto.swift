//
//  CharacterDto.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation

struct CharacterDto: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let modified: String?
    let resourceURI: String?
    let urls: [UrlInfoDto]?
    let thumbnail: [String:String]?
    let comics: ComicListDto?
    let stories: StoryListDto?
    let events: EventListDto?
    let series: SeriesListDto?
}
