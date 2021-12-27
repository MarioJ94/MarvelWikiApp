//
//  MarvelCharactersEndpoint.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation
import Alamofire

enum MarvelCharactersEndpoint {
    private enum ParameterKey {
        static let offset = "offset"
        static let limit = "limit"
        static let nameStartsWith = "nameStartsWith"
        static let apiKey = "apikey"
        static let timestamp = "ts"
        static let hash = "hash"
        static let characterId = "hash"
    }
    
    case character(apiKey: String,
                   hash: String,
                   timestamp: String,
                   id: Int)
    case charactersList(apiKey: String,
                        hash: String,
                        timestamp: String,
                        offset: Int,
                        limit: Int,
                        nameStartsWith: String?)
}

extension MarvelCharactersEndpoint: EndpointType {
    
    var host: String {
        return "gateway.marvel.com"
    }
    
    var path: String {
        switch self {
        case .character(_, _, _, let id):
            return "/v1/public/characters/\(id)"
        case .charactersList:
            return "/v1/public/characters"
        }
    }
    
    var httpMethod: API.HTTPMethod {
        switch self {
        case .character:
            return .get
        case .charactersList:
            return .get
        }
    }
    
    var urlParameters: API.Parameters {
        switch self {
        case .character(let apiKey, let hash, let timestamp, _):
            var params = API.Parameters()
            params[ParameterKey.apiKey] = apiKey
            params[ParameterKey.hash] = hash
            params[ParameterKey.timestamp] = timestamp
            return params
        case .charactersList(let apiKey, let hash, let timestamp, let offset, let limit, let nameStartsWith):
            var params = API.Parameters()
            params[ParameterKey.apiKey] = apiKey
            params[ParameterKey.hash] = hash
            params[ParameterKey.timestamp] = timestamp
            params[ParameterKey.offset] = "\(offset)"
            params[ParameterKey.limit] = "\(limit)"
            if let nameStartsWith = nameStartsWith {
                params[ParameterKey.nameStartsWith] = nameStartsWith
            }
            return params
        }
    }
    
    var bodyParameters: API.Parameters {
        switch self {
        case .character:
            return API.Parameters()
        case .charactersList:
            return API.Parameters()
        }
    }
    
    var scheme: String {
        switch self {
        case .character:
            return "https"
        case .charactersList:
            return "https"
        }
    }
    
    var port: Int {
        switch self {
        case .character:
            return 443
        case .charactersList:
            return 443
        }
    }
}

extension MarvelCharactersEndpoint : URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.host = self.host
        urlComponents.path = self.path
        urlComponents.scheme = self.scheme
        urlComponents.port = self.port
        
        let url = try urlComponents.asURL()
        var request = URLRequest(url: url)
        
        request.httpMethod = self.httpMethod.rawValue
        
        switch self {
        case .character:
            request = try URLEncodedFormParameterEncoder().encode(self.urlParameters, into: request)
        case .charactersList:
            request = try URLEncodedFormParameterEncoder().encode(self.urlParameters, into: request)
        }
        return request
    }
}
