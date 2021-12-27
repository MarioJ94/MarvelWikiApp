//
//  SeriesListDecodingTests.swift
//  TestMarvelAPITests
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation
import Combine
import XCTest
@testable import TestMarvelAPI

class SeriesListDecodingTests: XCTestCase {
    
    private var sut: Data?
    private typealias DecodingType = SeriesListDto

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    // MARK: - Utils
    private func dataOf(file: String, fileExtension: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: file, ofType: fileExtension) ?? ""
        let url = URL(fileURLWithPath: path)
        return try Data(contentsOf: url)
    }
    
    // MARK: - Sut providers
    private func provideData() throws -> Data? {
        let filename = "SeriesListMock"
        let fileExtension = "json"
        return try dataOf(file: filename, fileExtension: fileExtension)
    }
    
    // MARK: - Given
    private func givenData() throws {
        self.sut = try self.provideData()
    }
    
    // MARK: - Tests
    
    func test_testDecoding() {
        do {
            try self.givenData()
        } catch {
            XCTFail()
            return
        }
        
        guard let sut = sut else {
            XCTFail()
            return
        }
        
        let parseExpct = XCTestExpectation(description: "Parse complete")
        let decodeResult : Result<DecodingType, Error> = DecodingUtils.decodeJSON(from: sut)
        switch decodeResult {
        case .failure(let error):
            XCTFail(error.localizedDescription)
            return
        case .success(let model):
            XCTAssert(model.available == 3)
            XCTAssert(model.collectionURI == "http://gateway.marvel.com/v1/public/characters/1011334/series")
            XCTAssertNotNil(model.items)
            XCTAssert(model.items?.count == 3)
            XCTAssert(model.returned == 3)
            parseExpct.fulfill()
        }
        wait(for: [parseExpct], timeout: 1)
    }
}
