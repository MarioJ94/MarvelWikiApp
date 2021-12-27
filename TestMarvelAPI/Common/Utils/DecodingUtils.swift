//
//  DecodingUtils.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation

final class DecodingUtils {
    static func decodeJSON<T:Decodable>(from data: Data) -> Result<T, Error> {
        do {
            let decoder = JSONDecoder()
            let successValue = try decoder.decode(T.self, from: data)
            return .success(successValue)
        } catch {
            return .failure(error)
        }
    }
}
