//
//  CharactersAPIRequestParams.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation

enum CharactersAPIRequestParams {
    struct GetCharacter {
        let id: Int
    }
    
    struct GetCharactersList {
        let nameStartsWith : String?
        let offset : Int
        let limit : Int
    }
}
