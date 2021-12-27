//
//  CharacterListDecodingTests.swift
//  TestMarvelAPITests
//
//  Created by Mario Julià on 27/12/21.
//

import Foundation
import Combine
import XCTest
@testable import TestMarvelAPI

class CharacterListDecodingTests: XCTestCase {
    
    private var sut: Data?
    private typealias DecodingType = CharacterListDto

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
        let filename = "CharacterListMock"
        let fileExtension = "json"
        return try dataOf(file: filename, fileExtension: fileExtension)
    }
    
    // MARK: - Given
    private func givenData() throws {
        self.sut = try self.provideData()
    }
    
    // MARK: - Tests
    
    func test_testCharacterListDecoding() {
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
            XCTAssert(model.code == 200)
            XCTAssert(model.status == "Ok")
            XCTAssert(model.copyright == "© 2021 MARVEL")
            XCTAssert(model.attributionText == "Data provided by Marvel. © 2021 MARVEL")
            XCTAssert(model.attributionHTML == "<a href=\"http://marvel.com\">Data provided by Marvel. © 2021 MARVEL</a>")
            XCTAssert(model.etag == "4bb4a4be9bbf3f35a6dc842c2a62427d637e0eff")
            XCTAssertNotNil(model.data)
            parseExpct.fulfill()
        }
        wait(for: [parseExpct], timeout: 1)
    }
}
