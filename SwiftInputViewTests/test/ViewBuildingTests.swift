//
//  ViewBuildingTests.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit
import SwiftUIUtilities
import SwiftUtilities
import SwiftUtilitiesTests
import XCTest
@testable import SwiftInputView

class ViewBuildingTests: XCTestCase {
    let tries = 2000
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_buildAndConfigWithInputs_shouldIncludeAppropriateViews() {
        // Setup
        let allInputs = (0..<tries).map({_ in InputDetail.randomValues})
        let allBuilders = allInputs.map(InputViewBuilder.init)
        
        let view = UIAdaptableInputView()
        
        let testBuilder: (UIView, InputDetail) -> Void = {
            let componentViews = $0.0.subviews
            let decorator = $0.1.decorator as! TextInputViewDecoratorType
            
            let inputField = componentViews.filter({
                $0.accessibilityIdentifier == self.inputFieldId
            }).first
            
            XCTAssertTrue(inputField is InputFieldType)
            
            if let inputField = inputField as? InputFieldType {
                XCTAssertEqual(inputField.autocorrectionType, .no)
                
                if let inputTextColor = decorator.inputTextColor {
                    XCTAssertEqual(inputField.textColor, inputTextColor)
                }
                
                if let inputTintColor = decorator.inputTintColor {
                    XCTAssertEqual(inputField.tintColor, inputTintColor)
                }
            }
            
            if $0.1.displayRequiredIndicator {
                let indicator = componentViews.filter({
                    $0.accessibilityIdentifier == self.requiredIndicatorId
                }).first
                
                XCTAssertTrue(indicator is UILabel)
                
                if let indicator = indicator as? UILabel {
                    XCTAssertEqual(indicator.text, decorator.requiredIndicatorText)
                    
                    if let riTextColor = decorator.requiredIndicatorTextColor {
                        XCTAssertEqual(indicator.textColor, riTextColor)
                    }
                }
            }
        }
        
        // When & Then
        for builder in allBuilders {
            let subviews = builder.subviews(for: view)
            let inputs = builder.inputs.flatMap({$0 as? InputDetail})
            
            view.populateSubviews(with: builder)
            
            if inputs.count == 1, let input = inputs.first {
                testBuilder(view, input)
            } else {
                XCTAssertEqual(inputs.count, subviews.count)
                
                for (input, subview) in zip(inputs, subviews) {
                    XCTAssertTrue(subview is UIInputComponentView)
                    testBuilder(subview, input)
                }
            }
            
            view.subviews.forEach({$0.removeFromSuperview()})
            view.constraints.forEach({view.removeConstraint($0)})
        }
    }
}

extension XCTestCase: TextInputViewIdentifierType {}

enum InputDetail: Int {
    case mock1 = 1
    case mock2
    case mock3
    case mock4
    case mock5
    case mock6
    case mock7
    case mock8
    case mock9
    case mock10
    
    static var values: [InputDetail] {
        return (mock1.rawValue...mock10.rawValue).flatMap(InputDetail.init)
    }
    
    static var randomValues: [InputDetail] {
        let values = self.values
        let upperBound = Int.random(1, values.count)
        return values[0..<upperBound].map(eq)
    }
}

extension InputDetail: InputViewDetailType {
    public var viewBuilderComponentType: InputViewBuilderComponentType.Type? {
        return nil
    }

    var identifier: String { return String(describing: rawValue) }
    var isRequired: Bool { return rawValue.isEven }
    var inputType: InputType { return TextInput.default }
    var shouldDisplayRequiredIndicator: Bool { return rawValue % 4 == 0 }
    var decorator: InputViewDecoratorType { return InputDecorator.shared }
    var inputWidth: CGFloat? { return nil }
    var inputHeight: CGFloat? { return nil }
    var placeholder: String? { return nil }
}

class InputDecorator: TextInputViewDecoratorType {
    static var shared = InputDecorator()
    
    var inputBackgroundColor: UIColor { return .gray }
    var inputCornerRadius: CGFloat { return 5 }
    var inputTextColor: UIColor { return .white }
    var inputTintColor: UIColor { return .white }
    var requiredIndicatorTextColor: UIColor { return .white }
    var requiredIndicatorText: String { return "*R" }
    var placeholderTextColor: UIColor { return .lightGray }
}
