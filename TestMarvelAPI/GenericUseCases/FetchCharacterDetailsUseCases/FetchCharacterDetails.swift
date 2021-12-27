//
//  FetchCharacterDetails.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation
import Combine

final class FetchCharacterDetails {
    private let api : CharactersAPIOperationProtocol

    init(api: CharactersAPIOperationProtocol) {
        self.api = api
    }
}

extension FetchCharacterDetails : FetchCharacterDetailsUseCase {
    func execute(withParams: CharactersAPIRequestParams.GetCharacter) -> AnyPublisher<CharacterListDto, CharacterDetailsFetchError> {
        return api.getCharacter(queryParams: withParams)
            .catch({ error in
                return Fail(error: .fetchError(error: error))
            }).eraseToAnyPublisher()
    }
}
