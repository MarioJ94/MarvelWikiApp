//
//  CharacterListProcessorForCharacterDetailsUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

enum CharacterListProcessorForCharacterDetailsError : Error {
    case noCharacterReturned
    case characterToReturnUnclear
}

protocol CharacterListProcessorForCharacterDetailsUseCase {
    func execute(with listDto: CharacterListDto) throws -> CharacterDto
}
