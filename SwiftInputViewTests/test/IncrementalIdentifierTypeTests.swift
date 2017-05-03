//
//  IncrementalIdentifierTypeTests.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import XCTest
@testable import SwiftInputView

class IncrementalIdentifierTypeTests: XCTestCase {
    func test_findingIncrementalElements_shouldSucceed() {
        // Setup
        let base = MockIncrementalIdType.baseIdentifier
        let count = 10
        let startingIndex = 0
        let mockType = MockIncrementalIdType(count: count)
        
        // When
        let elements = mockType.findAll(withBaseIdentifier: base,
                                        andStartingIndex: startingIndex)
        
        // Then
        XCTAssertEqual(elements.count, count)
    }
}

class MockIncrementalIdType: IncrementalIdentifierType {
    typealias Element = String
    
    static var baseIdentifier: String {
        return "base"
    }
    
    let strings: [String]
    
    init(count: Int) {
        let base = MockIncrementalIdType.baseIdentifier
        strings = (0..<count).map({"\(base)\($0)"})
    }
    
    func findElement(with identifier: String) -> String? {
        return strings.filter(identifier.equals).first
    }
}
