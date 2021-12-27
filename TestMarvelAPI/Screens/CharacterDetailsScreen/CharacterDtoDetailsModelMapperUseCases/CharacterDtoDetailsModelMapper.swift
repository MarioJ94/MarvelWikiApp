//
//  CharacterDtoDetailsModelMapper.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

class CharacterDtoDetailsModelMapper {}

extension CharacterDtoDetailsModelMapper: CharacterDtoDetailsModelMapperUseCase {
    func execute(with character: CharacterDto) throws -> CharacterDetailsScreenModel {
        guard let name = character.name else {
            throw CharacterDtoDetailsModelMapperError.missingRelevantInformation
        }
        var thumbnail : String? = nil
        if let path = character.thumbnail?["path"], let ext = character.thumbnail?["extension"] {
            thumbnail = path.appendPathExtension(ext: ext)
        }
        let desc : String
        if let descrip = character.description, !descrip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            desc = descrip
        } else {
            desc = "No description"
        }
        
        let comicsAppearances : CharacterAppearancesModel
        if let comics = character.comics {
            let amount = comics.available ?? 0
            let list : [AppearanceRef] = comics.items?.map { dto in
                let name = dto.name ?? "Unknown"
                let url = dto.resourceURI
                let appearance = AppearanceRef(name: name, url: url)
                return appearance
            } ?? []
            comicsAppearances = CharacterAppearancesModel(link: comics.collectionURI, count: amount, appearancesList: list)
        } else {
            comicsAppearances = CharacterAppearancesModel(link: nil, count: 0, appearancesList: [])
        }
        
        let seriesAppearances : CharacterAppearancesModel
        if let series = character.series {
            let amount = series.available ?? 0
            let list : [AppearanceRef] = series.items?.map { dto in
                let name = dto.name ?? "Unknown"
                let url = dto.resourceURI
                let appearance = AppearanceRef(name: name, url: url)
                return appearance
            } ?? []
            seriesAppearances = CharacterAppearancesModel(link: series.collectionURI, count: amount, appearancesList: list)
        } else {
            seriesAppearances = CharacterAppearancesModel(link: nil, count: 0, appearancesList: [])
        }
        
        let storiesAppearances : CharacterAppearancesModel
        if let stories = character.stories {
            let amount = stories.available ?? 0
            let list : [AppearanceRef] = stories.items?.map { dto in
                let name = dto.name ?? "Unknown"
                let url = dto.resourceURI
                let appearance = AppearanceRef(name: name, url: url)
                return appearance
            } ?? []
            storiesAppearances = CharacterAppearancesModel(link: stories.collectionURI, count: amount, appearancesList: list)
        } else {
            storiesAppearances = CharacterAppearancesModel(link: nil, count: 0, appearancesList: [])
        }
        
        let eventsAppearances : CharacterAppearancesModel
        if let events = character.events {
            let amount = events.available ?? 0
            let list : [AppearanceRef] = events.items?.map { dto in
                let name = dto.name ?? "Unknown"
                let url = dto.resourceURI
                let appearance = AppearanceRef(name: name, url: url)
                return appearance
            } ?? []
            eventsAppearances = CharacterAppearancesModel(link: events.collectionURI, count: amount, appearancesList: list)
        } else {
            eventsAppearances = CharacterAppearancesModel(link: nil, count: 0, appearancesList: [])
        }
        
        let model = CharacterDetailsScreenModel(name: name,
                                                thumbnail: thumbnail,
                                                description: desc,
                                                comicsAppearances: comicsAppearances,
                                                seriesAppearances: seriesAppearances,
                                                storiesAppearances: storiesAppearances,
                                                eventsAppearances: eventsAppearances)
        return model
    }
}
