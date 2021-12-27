//
//  CharacterListViewerSearchViewModelUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 3/1/22.
//

import Foundation
import Combine

enum CharacterListSearchViewerError : Error {
    case Error(error: CharacterListViewerError, searchCriteria: String)
}

protocol CharacterListViewerSearchViewModelUseCase {
    var characterListSearchViewModelPublisher : AnyPublisher<Result<CharacterSearchListDisplayModel, CharacterListSearchViewerError>, Never> { get }
    func loadIfNeeded(page: Int, searchCriteria: String)
    func canLoadMoreContents(currentItemsOnDisplay: Int) -> Bool
    func reset()
}
