//
//  CharacterDetailsScreenViewModelUseCase.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation
import Combine

protocol CharacterDetailsScreenViewModelUseCase {
    func dataPublisher() -> AnyPublisher<Result<CharacterDetailsScreenModel, CharacterDetailsScreenViewModelError>, Never>
    func updateData()
}
