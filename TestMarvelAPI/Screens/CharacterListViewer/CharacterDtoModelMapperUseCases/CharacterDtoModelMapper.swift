//
//  CharacterDtoModelMapper.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 2/1/22.
//

import Foundation

class CharacterDtoModelMapper {}

extension CharacterDtoModelMapper: CharacterDtoModelMapperUseCase {
    func execute(with entryModel: CharacterDto) -> CharacterModel {
        var thumbnail = ""
        if let path = entryModel.thumbnail?["path"], let ext = entryModel.thumbnail?["extension"] {
            thumbnail = path.appendPathExtension(ext: ext)
        }
        let name : String
        if let charName = entryModel.name, !charName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            name = charName
        } else {
            name = "NO_NAME"
        }
        
        let modelId : String
        if let charID = entryModel.id {
            modelId = "\(charID)"
        } else {
            modelId = UUID().uuidString
        }
        let viewModel = CharacterModel(modelId: modelId, characterId: entryModel.id, name: name, thumbnail: thumbnail)
        return viewModel
    }
}
