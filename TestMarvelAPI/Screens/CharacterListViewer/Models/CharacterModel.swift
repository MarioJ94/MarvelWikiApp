//
//  CharacterModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

struct CharacterModel : Hashable {
    let modelId : String
    let characterId : Int?
    let name : String
    let thumbnail : String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(modelId)
        hasher.combine(characterId)
    }
}
