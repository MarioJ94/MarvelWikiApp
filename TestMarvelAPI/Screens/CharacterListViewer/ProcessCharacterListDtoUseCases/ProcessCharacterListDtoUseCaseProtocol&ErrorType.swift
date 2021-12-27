//
//  ProcessCharacterListDtoUseCaseProtocol&ErrorType.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

enum ProcessCharacterListDtoError : Error {
    case noTotal
    case noPagedContent
}

protocol ProcessCharacterListDtoUseCase {
    func execute(with dto: CharacterListDto) throws -> ProcessedCharacterListPage
}
