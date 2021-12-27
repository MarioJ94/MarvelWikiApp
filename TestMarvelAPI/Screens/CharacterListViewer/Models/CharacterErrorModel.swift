//
//  CharacterErrorModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

struct CharacterErrorModel : Hashable {
    let name : String
    let errorId : String
    let thumbnailFileName : String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(errorId)
    }
}
