//
//  ExtractCharacterDtoFromCharacterListDto.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

final class ExtractCharacterDtoFromCharacterListDto {
    
}

extension ExtractCharacterDtoFromCharacterListDto : CharacterListProcessorForCharacterDetailsUseCase {
    func execute(with listDto: CharacterListDto) throws -> CharacterDto {
        guard let results = listDto.data?.results, results.count > 0 else {
            throw CharacterListProcessorForCharacterDetailsError.noCharacterReturned
        }
        guard results.count == 1, let dto = results.first else {
            throw CharacterListProcessorForCharacterDetailsError.characterToReturnUnclear
        }
        return dto
    }
}
