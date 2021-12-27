//
//  Assembly+ScreenViewControllers.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 29/12/21.
//

import Foundation
import UIKit

// MARK: - CharacterListViewer
extension Assembly {
    func provideCharacterListViewerWithSearch() -> UIViewController {
        let fetchPageUseCase = FetchCharacterListPage(api: AppServices.shared.charactersAPI)
        let pageDtoProcessor = ProcessCharacterListDtoResponse()
        let mapper = CharacterDtoModelMapper()
        
        let viewModel = CharacterListViewerViewModel(fetchPageUseCase: fetchPageUseCase,
                                                     numberOfItemsPerPage: 50,
                                                     pageDtoProcessor: pageDtoProcessor,
                                                     characterDtoModelMapper: mapper)
        let searchViewModel = CharacterListViewerSearchViewModel(fetchPageUseCase: fetchPageUseCase,
                                                                 numberOfItemsPerPage: 25,
                                                                 pageDtoProcessor: pageDtoProcessor,
                                                                 characterDtoModelMapper: mapper)
        let vc = CharacterListViewerViewController()
        vc.viewModel = viewModel
        vc.searchViewModel = searchViewModel
        return vc
    }
}

extension Assembly {
    func provideCharacterDetailsScreen(withCharacterId characterId: Int) -> UIViewController {
        let params = CharactersAPIRequestParams.GetCharacter(id: characterId)
        let processor = ExtractCharacterDtoFromCharacterListDto()
        let detailsMapper = CharacterDtoDetailsModelMapper()
        let fetchDetailsUseCase = FetchCharacterDetails(api: AppServices.shared.charactersAPI)
        let viewModel = CharacterDetailsScreenViewModel(fetchDetailsUseCase: fetchDetailsUseCase,
                                                        characterListProcessorUseCase: processor,
                                                        dtoMapperUseCase: detailsMapper,
                                                        params: params)
        let vc = CharacterDetailsScreenViewController()
        vc.viewModel = viewModel
        return vc
    }
}
