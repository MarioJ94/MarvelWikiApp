//
//  AppServices.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation

class AppServices {
    static var shared = AppServices()
    
    private(set) var charactersAPI: CharactersAPIOperationProtocol
    
    private init() {
        self.charactersAPI = Assembly.shared.provideCharactersAPI()
    }
}
