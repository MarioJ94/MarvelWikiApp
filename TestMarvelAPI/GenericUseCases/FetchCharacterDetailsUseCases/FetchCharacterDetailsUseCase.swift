//
//  FetchCharacterDetailsUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation
import Combine

enum CharacterDetailsFetchError : Error {
    case fetchError(error: Error)
}

protocol FetchCharacterDetailsUseCase {
    func execute(withParams: CharactersAPIRequestParams.GetCharacter) -> AnyPublisher<CharacterListDto, CharacterDetailsFetchError>
}
