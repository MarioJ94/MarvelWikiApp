//
//  CharactersAPI.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation
import Combine
import Alamofire

final class CharactersAPI {
    private let apiKey = ""
    private let hash = ""
    private let timestamp = ""
    private let session : Session
    
    init(session: Session = Session.default) {
        self.session = session
    }
}

extension CharactersAPI : CharactersAPIOperationProtocol {
    func getCharacter(queryParams: CharactersAPIRequestParams.GetCharacter) -> AnyPublisher<CharacterListDto, APIOperationError> {
        let endpoint = MarvelCharactersEndpoint.character(apiKey: self.apiKey, hash: self.hash, timestamp: self.timestamp, id: queryParams.id)
        let request : URLRequest
        do {
            request = try endpoint.asURLRequest()
        } catch {
            return Fail<CharacterListDto,APIOperationError>(error: APIOperationError.requestFailed).eraseToAnyPublisher()
        }
        
        let req = self.session.request(request)
        return req.validate()
            .publishData()
            .value()
            .catch { error in
                return Fail(error: APIOperationError.requestFailed)
            }
            .decode(type: CharacterListDto.self, decoder: JSONDecoder())
            .catch { error in
                return Fail(error: APIOperationError.decodingError(error: error))
            }.eraseToAnyPublisher()
    }
    
    func getCharacterList(queryParams: CharactersAPIRequestParams.GetCharactersList) -> AnyPublisher<CharacterListDto, APIOperationError> {
        let endpoint = MarvelCharactersEndpoint.charactersList(apiKey: self.apiKey, hash: self.hash, timestamp: self.timestamp, offset: queryParams.offset, limit: queryParams.limit, nameStartsWith: queryParams.nameStartsWith)
        let request : URLRequest
        do {
            request = try endpoint.asURLRequest()
        } catch {
            return Fail<CharacterListDto,APIOperationError>(error: APIOperationError.requestFailed).eraseToAnyPublisher()
        }

        let req = self.session.request(request)
        return req.validate().publishData()
            .value()
            .catch { error in
                return Fail(error: APIOperationError.requestFailed)
            }
            .decode(type: CharacterListDto.self, decoder: JSONDecoder())
            .catch { error in
                return Fail(error: APIOperationError.decodingError(error: error))
            }.eraseToAnyPublisher()
    }
}
