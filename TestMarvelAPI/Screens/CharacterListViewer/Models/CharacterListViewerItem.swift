//
//  CharacterListViewerItem.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

enum CharacterListViewerItem: Hashable {
    case loaded(model: CharacterModel, page: Int)
    case error(model: CharacterErrorModel, page: Int)
}
