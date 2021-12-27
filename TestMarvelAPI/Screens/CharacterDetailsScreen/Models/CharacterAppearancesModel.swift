//
//  CharacterAppearancesModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 6/1/22.
//

import Foundation

struct CharacterAppearancesModel: Equatable {
    let link : String?
    let count : Int
    let appearancesList: [AppearanceRef]
}
