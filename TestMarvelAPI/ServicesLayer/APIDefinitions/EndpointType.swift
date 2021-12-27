//
//  EndpointType.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 28/12/21.
//

import Foundation

protocol EndpointType {
    var host: String { get }
    var path: String { get }
    var httpMethod: API.HTTPMethod { get }
    var urlParameters: API.Parameters { get }
    var scheme: String { get }
    var port: Int { get }
}
