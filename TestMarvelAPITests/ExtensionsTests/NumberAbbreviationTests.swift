//
//  NumberAbbreviationTests.swift
//  TestMarvelAPITests
//
//  Created by Mario Julià on 7/1/22.
//

import XCTest
@testable import TestMarvelAPI

class NumberAbbreviationTests: XCTestCase {
    private struct AbbreviationExpectation {
        let input : NSNumber
        let output : NSNumber.NumberAbbreviationDescriptor
    }
    
    func testPositiveIntegers() throws {
        var cases : [AbbreviationExpectation] = []
        cases.append(AbbreviationExpectation(input: 0,          output: .init(type: .noSuffixNeeded(number: 0),                     positive: true)))
        cases.append(AbbreviationExpectation(input: 1,          output: .init(type: .noSuffixNeeded(number: 1.0),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 999,        output: .init(type: .noSuffixNeeded(number: 999),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1000,       output: .init(type: .withSuffix(number: 1, suffix: "K"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1200,       output: .init(type: .withSuffix(number: 1.2, suffix: "K"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 1290,       output: .init(type: .withSuffix(number: 1.2, suffix: "K"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 10000,      output: .init(type: .withSuffix(number: 10, suffix: "K"),           positive: true)))
        cases.append(AbbreviationExpectation(input: 11000,      output: .init(type: .withSuffix(number: 11, suffix: "K"),           positive: true)))
        cases.append(AbbreviationExpectation(input: 11900,      output: .init(type: .withSuffix(number: 11.9, suffix: "K"),         positive: true)))
        cases.append(AbbreviationExpectation(input: 100000,     output: .init(type: .withSuffix(number: 100, suffix: "K"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 100400,     output: .init(type: .withSuffix(number: 100.4, suffix: "K"),        positive: true)))
        cases.append(AbbreviationExpectation(input: 100900,     output: .init(type: .withSuffix(number: 100.9, suffix: "K"),        positive: true)))
        cases.append(AbbreviationExpectation(input: 1000000,    output: .init(type: .withSuffix(number: 1, suffix: "M"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1000400,    output: .init(type: .withSuffix(number: 1, suffix: "M"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1100000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 1160000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 1199000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),          positive: true)))

        for abbreviationCase in cases {
            let descriptor = abbreviationCase.input.abbreviatedDescription(withMaxDecimals: 1)
            XCTAssert(descriptor.type == abbreviationCase.output.type, "Case with \(abbreviationCase.input) was abbreviated to \(descriptor), which does not match \(abbreviationCase.output)")
        }
    }

    func testPositiveDecimalPoints() {
        var cases : [AbbreviationExpectation] = []
        cases.append(AbbreviationExpectation(input: 0.4,        output: .init(type: .noSuffixNeeded(number: 0.4),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 0.6,        output: .init(type: .noSuffixNeeded(number: 0.6),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1.0,        output: .init(type: .noSuffixNeeded(number: 1.0),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1.4,        output: .init(type: .noSuffixNeeded(number: 1.4),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1.5,        output: .init(type: .noSuffixNeeded(number: 1.5),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1.53,       output: .init(type: .noSuffixNeeded(number: 1.5),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1.58,       output: .init(type: .noSuffixNeeded(number: 1.5),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 1.6,        output: .init(type: .noSuffixNeeded(number: 1.6),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 999.0,      output: .init(type: .noSuffixNeeded(number: 999),                   positive: true)))
        cases.append(AbbreviationExpectation(input: 999.9,      output: .init(type: .noSuffixNeeded(number: 999.9),                 positive: true)))
        cases.append(AbbreviationExpectation(input: 1000.4,     output: .init(type: .withSuffix(number: 1, suffix: "K"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1000.9,     output: .init(type: .withSuffix(number: 1, suffix: "K"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1200.9,     output: .init(type: .withSuffix(number: 1.2, suffix: "K"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 1290,       output: .init(type: .withSuffix(number: 1.2, suffix: "K"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 10000,      output: .init(type: .withSuffix(number: 10, suffix: "K"),           positive: true)))
        cases.append(AbbreviationExpectation(input: 11000,      output: .init(type: .withSuffix(number: 11, suffix: "K"),           positive: true)))
        cases.append(AbbreviationExpectation(input: 11900,      output: .init(type: .withSuffix(number: 11.9, suffix: "K"),         positive: true)))
        cases.append(AbbreviationExpectation(input: 100000,     output: .init(type: .withSuffix(number: 100, suffix: "K"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 100400,     output: .init(type: .withSuffix(number: 100.4, suffix: "K"),        positive: true)))
        cases.append(AbbreviationExpectation(input: 100900,     output: .init(type: .withSuffix(number: 100.9, suffix: "K"),        positive: true)))
        cases.append(AbbreviationExpectation(input: 1000000,    output: .init(type: .withSuffix(number: 1, suffix: "M"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1000400,    output: .init(type: .withSuffix(number: 1, suffix: "M"),            positive: true)))
        cases.append(AbbreviationExpectation(input: 1100000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 1160000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),          positive: true)))
        cases.append(AbbreviationExpectation(input: 1199000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),          positive: true)))

        for abbreviationCase in cases {
            let descriptor = abbreviationCase.input.abbreviatedDescription(withMaxDecimals: 1)
            XCTAssert(descriptor.type == abbreviationCase.output.type, "Case with \(abbreviationCase.input) was abbreviated to \(descriptor), which does not match \(abbreviationCase.output)")
        }
    }
    
    func testNegativeIntegers() throws {
        var cases : [AbbreviationExpectation] = []
        cases.append(AbbreviationExpectation(input: -0,          output: .init(type: .noSuffixNeeded(number: 0),                    positive: false)))
        cases.append(AbbreviationExpectation(input: -1,          output: .init(type: .noSuffixNeeded(number: 1.0),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -999,        output: .init(type: .noSuffixNeeded(number: 999),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1000,       output: .init(type: .withSuffix(number: 1, suffix: "K"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1200,       output: .init(type: .withSuffix(number: 1.2, suffix: "K"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -1290,       output: .init(type: .withSuffix(number: 1.2, suffix: "K"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -10000,      output: .init(type: .withSuffix(number: 10, suffix: "K"),          positive: false)))
        cases.append(AbbreviationExpectation(input: -11000,      output: .init(type: .withSuffix(number: 11, suffix: "K"),          positive: false)))
        cases.append(AbbreviationExpectation(input: -11900,      output: .init(type: .withSuffix(number: 11.9, suffix: "K"),        positive: false)))
        cases.append(AbbreviationExpectation(input: -100000,     output: .init(type: .withSuffix(number: 100, suffix: "K"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -100400,     output: .init(type: .withSuffix(number: 100.4, suffix: "K"),       positive: false)))
        cases.append(AbbreviationExpectation(input: -100900,     output: .init(type: .withSuffix(number: 100.9, suffix: "K"),       positive: false)))
        cases.append(AbbreviationExpectation(input: -1000000,    output: .init(type: .withSuffix(number: 1, suffix: "M"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1000400,    output: .init(type: .withSuffix(number: 1, suffix: "M"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1100000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -1160000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -1199000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),         positive: false)))

        for abbreviationCase in cases {
            let descriptor = abbreviationCase.input.abbreviatedDescription(withMaxDecimals: 1)
            XCTAssert(descriptor.type == abbreviationCase.output.type, "Case with \(abbreviationCase.input) was abbreviated to \(descriptor), which does not match \(abbreviationCase.output)")
        }
    }

    func testNegativeDecimalPoints() {
        var cases : [AbbreviationExpectation] = []
        cases.append(AbbreviationExpectation(input: -0.4,        output: .init(type: .noSuffixNeeded(number: 0.4),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -0.6,        output: .init(type: .noSuffixNeeded(number: 0.6),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1.0,        output: .init(type: .noSuffixNeeded(number: 1.0),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1.4,        output: .init(type: .noSuffixNeeded(number: 1.4),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1.5,        output: .init(type: .noSuffixNeeded(number: 1.5),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1.53,       output: .init(type: .noSuffixNeeded(number: 1.5),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1.58,       output: .init(type: .noSuffixNeeded(number: 1.5),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -1.6,        output: .init(type: .noSuffixNeeded(number: 1.6),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -999.0,      output: .init(type: .noSuffixNeeded(number: 999),                  positive: false)))
        cases.append(AbbreviationExpectation(input: -999.9,      output: .init(type: .noSuffixNeeded(number: 999.9),                positive: false)))
        cases.append(AbbreviationExpectation(input: -1000.4,     output: .init(type: .withSuffix(number: 1, suffix: "K"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1000.9,     output: .init(type: .withSuffix(number: 1, suffix: "K"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1200.9,     output: .init(type: .withSuffix(number: 1.2, suffix: "K"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -1290,       output: .init(type: .withSuffix(number: 1.2, suffix: "K"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -10000,      output: .init(type: .withSuffix(number: 10, suffix: "K"),          positive: false)))
        cases.append(AbbreviationExpectation(input: -11000,      output: .init(type: .withSuffix(number: 11, suffix: "K"),          positive: false)))
        cases.append(AbbreviationExpectation(input: -11900,      output: .init(type: .withSuffix(number: 11.9, suffix: "K"),        positive: false)))
        cases.append(AbbreviationExpectation(input: -100000,     output: .init(type: .withSuffix(number: 100, suffix: "K"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -100400,     output: .init(type: .withSuffix(number: 100.4, suffix: "K"),       positive: false)))
        cases.append(AbbreviationExpectation(input: -100900,     output: .init(type: .withSuffix(number: 100.9, suffix: "K"),       positive: false)))
        cases.append(AbbreviationExpectation(input: -1000000,    output: .init(type: .withSuffix(number: 1, suffix: "M"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1000400,    output: .init(type: .withSuffix(number: 1, suffix: "M"),           positive: false)))
        cases.append(AbbreviationExpectation(input: -1100000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -1160000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),         positive: false)))
        cases.append(AbbreviationExpectation(input: -1199000,    output: .init(type: .withSuffix(number: 1.1, suffix: "M"),         positive: false)))

        for abbreviationCase in cases {
            let descriptor = abbreviationCase.input.abbreviatedDescription(withMaxDecimals: 1)
            XCTAssert(descriptor.type == abbreviationCase.output.type, "Case with \(abbreviationCase.input) was abbreviated to \(descriptor), which does not match \(abbreviationCase.output)")
        }
    }
    
    func testDifferentNumberOfDecimals() {
        var cases : [AbbreviationExpectation] = []
        let number : NSNumber = 0.123456789123456789
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0),                             positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.1),                           positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.12),                          positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.123),                         positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.1234),                        positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.12345),                       positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.123456),                      positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.1234567),                     positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.12345678),                    positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.123456789),                   positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.1234567891),                  positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.12345678912),                 positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.123456789123),                positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.1234567891234),               positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.12345678912345),              positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.123456789123456),             positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.1234567891234567),            positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.12345678912345678),           positive: true)))
        cases.append(AbbreviationExpectation(input: number, output: .init(type: .noSuffixNeeded(number: 0.123456789123456789),          positive: true)))

        for i in 0..<cases.count {
            let caseElement = cases[i]
            let descriptor = caseElement.input.abbreviatedDescription(withMaxDecimals: i)
            XCTAssert(descriptor.positive == caseElement.output.positive, "No positive equality")
            let power = Double(-i)
            switch (descriptor.type, caseElement.output.type) {
            case (.noSuffixNeeded(let a), .noSuffixNeeded(number: let b)):
                XCTAssertEqual(a.doubleValue, b.doubleValue, accuracy: pow(10, power))
            case (.withSuffix(let numberA, let suffixA), .withSuffix(let numberB, let suffixB)):
                XCTAssertEqual(numberA.doubleValue, numberB.doubleValue, accuracy: pow(10, power), "No value equality")
                XCTAssert(suffixA == suffixB, "No suffix equality")
            default:
                XCTAssert(descriptor.type == caseElement.output.type, "Case with \(caseElement.input) was abbreviated to \(descriptor), which does not match \(caseElement.output)")
            }
        }
    }
}
