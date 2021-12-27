//
//  CharacterDtoDetailsModelMapperUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

enum CharacterDtoDetailsModelMapperError : Error {
    case missingRelevantInformation
}

protocol CharacterDtoDetailsModelMapperUseCase {
    func execute(with entryModel: CharacterDto) throws -> CharacterDetailsScreenModel
}
