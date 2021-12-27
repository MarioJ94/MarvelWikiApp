//
//  ProcessCharacterListDtoResponse.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

final class ProcessCharacterListDtoResponse : ProcessCharacterListDtoUseCase {
    func execute(with dto: CharacterListDto) throws -> ProcessedCharacterListPage {
        guard let characters = dto.data?.results else {
            throw ProcessCharacterListDtoError.noPagedContent
        }
        guard let total = dto.data?.total else {
            throw ProcessCharacterListDtoError.noTotal
        }
        let processed = ProcessedCharacterListPage(characters: characters, total: total)
        return processed
    }
}
