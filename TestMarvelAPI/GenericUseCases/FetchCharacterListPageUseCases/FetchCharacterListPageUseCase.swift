//
//  FetchCharacterListPageUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation
import Combine

enum CharacterListFetchError : Error {
    case fetchError(error: Error)
}

protocol FetchCharacterListPageUseCase {
    func execute(withParams: CharactersAPIRequestParams.GetCharactersList) -> AnyPublisher<CharacterListDto, CharacterListFetchError>
}
