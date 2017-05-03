//
//  InputHolderViewTypeTests.swift
//  SwiftInputView
//
//  Created by Hai Pham on 5/3/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import UIKit
import XCTest
@testable import SwiftInputView

class InputHolderViewTypeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_getControllerPresenter_shouldSucceed() {
        let tries = 1000
        let viewCount = 100
        
        for _ in 0..<tries {
            // Setup
            let views = Array(repeating: {_ in MockInputHolderView()},
                              for: viewCount)
            
            for (index, view) in views.enumerated() {
                if let next = views.element(at: index + 1) {
                    view.addSubview(next)
                }
            }
            
            let presenter = MockControllerPresenter()
            let index = Int.random(0, viewCount)
            views.element(at: index)!.controllerPresentable = presenter
            
            let last = views.last!
            
            // When
            let instance = last.controllerPresenter
            
            // Then
            XCTAssertNotNil(instance)
            XCTAssertTrue(instance is MockControllerPresenter)
            XCTAssertEqual(instance as! MockControllerPresenter, presenter)
        }
    }
}

fileprivate class MockControllerPresenter: ControllerPresentableType {
    fileprivate static var counter: Int = 0
    
    fileprivate let count: Int
    
    fileprivate init() {
        count = MockControllerPresenter.counter
        MockControllerPresenter.counter += 1
    }
    
    func presentController(_ controller: UIViewController,
                           animated: Bool,
                           completion: (() -> Void)?) {}
}

extension MockControllerPresenter: Hashable {
    public static func ==(lhs: MockControllerPresenter,
                          rhs: MockControllerPresenter) -> Bool {
        return lhs.count == rhs.count
    }

    var hashValue: Int { return count.hashValue }
}

fileprivate class MockInputHolderView: UIView, InputHolderViewType {
    weak var controllerPresentable: ControllerPresentableType?
}
