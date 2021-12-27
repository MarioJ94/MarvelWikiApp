//
//  CharacterDtoModelMapperUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

protocol CharacterDtoModelMapperUseCase {
    func execute(with entryModel: CharacterDto) -> CharacterModel
}
