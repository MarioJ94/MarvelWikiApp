//
//  CharacterDetailsScreenViewModel.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation
import Combine

final class CharacterDetailsScreenViewModel {
    
    private let publisher = PassthroughSubject<Result<CharacterDetailsScreenModel, CharacterDetailsScreenViewModelError>, Never>()
    
    private let fetchDetailsUseCase: FetchCharacterDetailsUseCase
    private let characterListProcessorUseCase: CharacterListProcessorForCharacterDetailsUseCase
    private let dtoMapperUseCase: CharacterDtoDetailsModelMapperUseCase
    private let params: CharactersAPIRequestParams.GetCharacter
    private var updateSubscription : AnyCancellable? = nil
    private var currentDto : CharacterDto?
    
    init(fetchDetailsUseCase: FetchCharacterDetailsUseCase,
         characterListProcessorUseCase: CharacterListProcessorForCharacterDetailsUseCase,
         dtoMapperUseCase: CharacterDtoDetailsModelMapperUseCase,
         params: CharactersAPIRequestParams.GetCharacter) {
        self.fetchDetailsUseCase = fetchDetailsUseCase
        self.characterListProcessorUseCase = characterListProcessorUseCase
        self.dtoMapperUseCase = dtoMapperUseCase
        self.params = params
    }
}

extension CharacterDetailsScreenViewModel: CharacterDetailsScreenViewModelUseCase {
    func dataPublisher() -> AnyPublisher<Result<CharacterDetailsScreenModel, CharacterDetailsScreenViewModelError>, Never> {
        return self.publisher.eraseToAnyPublisher()
    }
    
    func updateData() {
        print("Started details fetch request")
        let listDtoProcessor = self.characterListProcessorUseCase
        let dtoPublisher = self.fetchDetailsUseCase.execute(withParams: self.params)
            .receive(on: DispatchQueue.main)
            .tryMap({ listDto -> CharacterDto in
                return try listDtoProcessor.execute(with: listDto)
            }).eraseToAnyPublisher()
        
        let mapper = dtoMapperUseCase
        self.updateSubscription = dtoPublisher.tryMap({ dto -> (model: CharacterDetailsScreenModel, dto: CharacterDto) in
            let mapped = try mapper.execute(with: dto)
            return (mapped, dto)
        }) .sink(receiveCompletion: { [weak self] complResult in
            self?.updateSubscription = nil
            switch complResult {
            case .failure(let error):
                print("Error in details fetch request: \(error.localizedDescription)")
                self?.handleError(error: error)
            case .finished:
                print("Success in details fetch request")
            }
        }, receiveValue: { [weak self] value in
            self?.handleNewDetails(value: value)
        })
    }
    
    private func handleError(error: Error) {
        self.publisher.send(.failure(.fetchDetailsError))
    }
    
    private func handleNewDetails(value: (model: CharacterDetailsScreenModel, dto: CharacterDto)) {
        self.currentDto = value.dto
        self.publishModel(model: value.model)
    }
    
    private func publishModel(model: CharacterDetailsScreenModel) {
        self.publisher.send(.success(model))
    }
}
