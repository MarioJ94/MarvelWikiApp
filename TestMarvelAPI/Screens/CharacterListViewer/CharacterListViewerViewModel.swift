//
//  CharacterListViewerViewModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation
import Combine

final class CharacterListViewerViewModel {
    private typealias Page = Int
    
    private let publisher = PassthroughSubject<Result<CharactersListDisplayModel, CharacterListViewerError>, Never>()
    
    private var pagedModels = [Page:[CharacterDto]]()
    private let fetchPageUseCase : FetchCharacterListPageUseCase
    private var subscriptions = [Page:AnyCancellable]()
    private let numberOfItemsPerPage : Int
    private let characterDtoModelMapper : CharacterDtoModelMapperUseCase
    private let pageDtoProcessor: ProcessCharacterListDtoUseCase
    private var lastTotalResults : PaginatedContentTotalResults = .notFetched
    
    init(fetchPageUseCase: FetchCharacterListPageUseCase,
         numberOfItemsPerPage: Int,
         pageDtoProcessor: ProcessCharacterListDtoUseCase,
         characterDtoModelMapper: CharacterDtoModelMapperUseCase) {
        self.fetchPageUseCase = fetchPageUseCase
        self.pageDtoProcessor = pageDtoProcessor
        self.numberOfItemsPerPage = numberOfItemsPerPage
        self.characterDtoModelMapper = characterDtoModelMapper
    }
}

extension CharacterListViewerViewModel: CharacterListViewerViewModelUseCase {
    var characterListListViewModelPublisher: AnyPublisher<Result<CharactersListDisplayModel, CharacterListViewerError>, Never> {
        return self.publisher.eraseToAnyPublisher()
    }
    
    private func canFetchPage(page: Int) -> Bool {
        switch self.lastTotalResults {
        case .notFetched:
            return true
        case .fetched(let number):
            return page * self.numberOfItemsPerPage < number
        case .totalChanged:
            return false
        }
    }
    
    func canDisplayHintToLoadMoreContents(currentItemsOnDisplay: Int) -> Bool {
        switch self.lastTotalResults {
        case .notFetched:
            return false
        case .fetched(let number):
            return currentItemsOnDisplay < number
        case .totalChanged:
            return false
        }
    }
    
    func reset() {
        self.subscriptions.removeAll()
        self.pagedModels.removeAll()
        self.lastTotalResults = .notFetched
    }
    
    func loadIfNeeded(page: Int) {
        guard self.canFetchPage(page: page), self.subscriptions[page] == nil && self.pagedModels[page] == nil else {
            return
        }
        print("Started request of \(page)")
        let offset = page * self.numberOfItemsPerPage
        let limit = self.numberOfItemsPerPage
        let params = CharactersAPIRequestParams.GetCharactersList(nameStartsWith: nil, offset: offset, limit: limit)
        let pageProcessor = self.pageDtoProcessor
        self.fetchPageUseCase.execute(withParams: params)
            .receive(on: DispatchQueue.main)
            .tryMap { dto -> ProcessedCharacterListPage in
                return try pageProcessor.execute(with: dto)
            }.sink { [weak self] complResult in
                self?.subscriptions.removeValue(forKey: page)
                switch complResult {
                case .failure(let error):
                    self?.handleFetchErrorFor(forPage: page)
                    print(error.localizedDescription)
                case .finished:
                    print("Finished request of \(page)")
                }
                if let subscriptions = self?.subscriptions {
                    print("Pending Subscriptions: \(subscriptions.count)")
                }
            } receiveValue: { [weak self] processedPage in
                self?.handleNewProcessedPageResponse(processedPage: processedPage, forPage: page)
            }.store(in: &self.subscriptions, forKey: page)
    }
    
    private func handleFetchErrorFor(forPage page: Int) {
        self.publisher.send(.failure(.FetchError(page: page)))
    }
    
    private func handleNewProcessedPageResponse(processedPage: ProcessedCharacterListPage, forPage page: Int) {
        switch self.lastTotalResults {
        case .fetched(let previousNumber):
            if processedPage.total != previousNumber {
                self.lastTotalResults = .totalChanged
                self.publisher.send(.failure(.TotalChanged))
                return
            }
        case .notFetched:
            break
        case .totalChanged:
            return
        }
        
        self.lastTotalResults = .fetched(number: processedPage.total)
        self.pagedModels[page] = processedPage.characters
        self.publishCurrentViewModel()
    }
    
    private func publishCurrentViewModel() {
        let viewModel = self.createViewModel()
        self.publisher.send(.success(viewModel))
    }
    
    private func createViewModel() -> CharactersListDisplayModel {
        let valuesOrdered = self.pagedModels.sorted { lhs, rhs in
            return lhs.key < rhs.key
        }.map({ $1 })
        let characterDtoMapper = self.characterDtoModelMapper
        let displayModel = valuesOrdered.enumerated().map({ element -> [CharacterListViewerItem] in
            let mappingResult = element.element.map({ characterDtoMapper.execute(with: $0) })
            return mappingResult.map({ return CharacterListViewerItem.loaded(model: $0, page: element.offset) })
        }).flatMap({ $0 })
        return CharactersListDisplayModel(entries: displayModel)
    }
}
