//
//  CharacterDetailsScreenModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation

struct CharacterDetailsScreenModel {
    let name : String
    let thumbnail : String?
    let description : String
    let comicsAppearances : CharacterAppearancesModel
    let seriesAppearances : CharacterAppearancesModel
    let storiesAppearances : CharacterAppearancesModel
    let eventsAppearances : CharacterAppearancesModel
}
