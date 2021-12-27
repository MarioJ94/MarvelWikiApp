//
//  CharacterListViewerSearchViewModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation
import Combine

final class CharacterListViewerSearchViewModel {
    private typealias Page = Int
    
    private let publisher = PassthroughSubject<Result<CharacterSearchListDisplayModel, CharacterListSearchViewerError>, Never>()

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

extension CharacterListViewerSearchViewModel : CharacterListViewerSearchViewModelUseCase {
    var characterListSearchViewModelPublisher: AnyPublisher<Result<CharacterSearchListDisplayModel, CharacterListSearchViewerError>, Never> {
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
    
    func canLoadMoreContents(currentItemsOnDisplay: Int) -> Bool {
        switch self.lastTotalResults {
        case .notFetched:
            return false
        case .fetched(let number):
            return currentItemsOnDisplay < number
        case .totalChanged:
            return false
        }
    }
    
    func loadIfNeeded(page: Int, searchCriteria: String) {
        guard self.canFetchPage(page: page), self.subscriptions[page] == nil && self.pagedModels[page] == nil else {
            return
        }
        
        print("Started request of \(page)")
        let offset = page * self.numberOfItemsPerPage
        let limit = self.numberOfItemsPerPage
        let params = CharactersAPIRequestParams.GetCharactersList(nameStartsWith: searchCriteria, offset: offset, limit: limit)
        let pageProcessor = self.pageDtoProcessor
        self.fetchPageUseCase.execute(withParams: params)
            .receive(on: DispatchQueue.main)
            .tryMap { dto -> ProcessedCharacterListPage in
                return try pageProcessor.execute(with: dto)
            }.sink { [weak self] complResult in
                self?.subscriptions.removeValue(forKey: page)
                switch complResult {
                case .failure(let error):
                    self?.handleFetchErrorFor(forPage: page, searchCrieria: searchCriteria)
                    print(error.localizedDescription)
                case .finished:
                    print("Finished request of \(page)")
                }
                if let subscriptions = self?.subscriptions {
                    print("Pending Subscriptions: \(subscriptions.count)")
                }
            } receiveValue: { [weak self] processedPage in
                self?.handleNewProcessedPageResponse(processedPage: processedPage, forPage: page, searchCrieria: searchCriteria)
            }.store(in: &self.subscriptions, forKey: page)
    }
    
    private func handleFetchErrorFor(forPage page: Int, searchCrieria: String) {
        self.publisher.send(.failure(.Error(error: .FetchError(page: page), searchCriteria: searchCrieria)))
    }
    
    private func handleNewProcessedPageResponse(processedPage: ProcessedCharacterListPage, forPage page: Int, searchCrieria: String) {
        switch self.lastTotalResults {
        case .fetched(let previousNumber):
            if processedPage.total != previousNumber {
                self.lastTotalResults = .totalChanged
                self.publisher.send(.failure(.Error(error: .TotalChanged, searchCriteria: searchCrieria)))
                return
            }
        case .notFetched:
            break
        case .totalChanged:
            return
        }
        
        if processedPage.total <= 0 {
            self.publisher.send(.failure(.Error(error: .NoResults, searchCriteria: searchCrieria)))
        }
        self.lastTotalResults = .fetched(number: processedPage.total)
        self.pagedModels[page] = processedPage.characters
        self.publishCurrentViewModel()
    }
    
    func reset() {
        self.lastTotalResults = .notFetched
        self.subscriptions.removeAll()
        self.pagedModels.removeAll()
    }
    
    private func publishCurrentViewModel() {
        let viewModel = self.createViewModel()
        self.publisher.send(.success(viewModel))
    }
    
    private func createViewModel() -> CharacterSearchListDisplayModel {
        let valuesOrdered = self.pagedModels.sorted { lhs, rhs in
            return lhs.key < rhs.key
        }.map({ $1 })
        let characterDtoMapper = self.characterDtoModelMapper
        let displayModel = valuesOrdered.enumerated().map({ element -> [CharacterListViewerItem] in
            let mappingResult = element.element.map({ characterDtoMapper.execute(with: $0) })
            return mappingResult.map({ return CharacterListViewerItem.loaded(model: $0, page: element.offset) })
        }).flatMap({ $0 })
        return CharacterSearchListDisplayModel(displayModel: CharactersListDisplayModel(entries: displayModel))
    }
}
