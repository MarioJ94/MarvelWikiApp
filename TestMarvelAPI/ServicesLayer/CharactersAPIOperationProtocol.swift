//
//  CharactersAPIOperationProtocol.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation
import Combine

protocol CharactersAPIOperationProtocol {
    func getCharacter(queryParams: CharactersAPIRequestParams.GetCharacter) -> AnyPublisher<CharacterListDto, APIOperationError>
    func getCharacterList(queryParams: CharactersAPIRequestParams.GetCharactersList) -> AnyPublisher<CharacterListDto, APIOperationError>
}
