//
//  Assembly+CharactersAPIOperationProtocol.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation

extension Assembly {
    func provideCharactersAPI() -> CharactersAPIOperationProtocol {
        let api = CharactersAPI()
        return api
    }
}
