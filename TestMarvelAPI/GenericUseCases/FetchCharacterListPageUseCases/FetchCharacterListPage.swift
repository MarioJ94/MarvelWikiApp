//
//  FetchCharacterListPage.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation
import Combine

final class FetchCharacterListPage : FetchCharacterListPageUseCase {
    private let api : CharactersAPIOperationProtocol
    
    init(api: CharactersAPIOperationProtocol) {
        self.api = api
    }
    
    func execute(withParams: CharactersAPIRequestParams.GetCharactersList) -> AnyPublisher<CharacterListDto, CharacterListFetchError> {
        return api.getCharacterList(queryParams: withParams)
            .catch({ error in
                return Fail(error: .fetchError(error: error))
            }).eraseToAnyPublisher()
    }
}
