//
//  CharacterListViewerViewModelUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation
import Combine

enum CharacterListViewerError : Error {
    case NoResults
    case InitialFetchError
    case FetchError(page: Int)
    case TotalChanged
}

protocol CharacterListViewerViewModelUseCase {
    var characterListListViewModelPublisher : AnyPublisher<Result<CharactersListDisplayModel, CharacterListViewerError>, Never> { get }
    func loadIfNeeded(page: Int)
    func canDisplayHintToLoadMoreContents(currentItemsOnDisplay: Int) -> Bool
    func reset()
}
