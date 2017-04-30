//
//  InputViewIdentifier.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Provide identifiers for input subviews.
public protocol InputViewIdentifierType {}

public extension InputViewIdentifierType {
    
    /// In case there are multiple inputs in one input view, we want to keep
    /// separate accessibility identifiers.
    ///
    /// - Parameter index: The index corresponding to the input's index.
    /// - Returns: A String value.
    func parentSubviewId(for index: Int) -> String {
        return "\(parentSubviewId)\(index)"
    }
    
    /// Identifier to get parent subviews.
    var parentSubviewId: String { return "parentSubview" }
    
    /// Use this to access direct width constraint.
    var parentSubviewWidthId: String { return "parentSubviewWidth" }
    
    /// Use this to access width ratio constraint.
    var parentSubviewWidthRatioId: String { return "parentSubviewWidthRatio" }
    
    /// Use this to access left constraint.
    var parentSubviewLeftId: String { return "parentSubviewLeft" }
}

/// Provide identifiers for text input subviews.
public protocol TextInputViewIdentifierType: InputViewIdentifierType {}

public extension TextInputViewIdentifierType {
    
    /// Identifier to get the input field.
    var inputFieldId: String { return "inputField" }
    
    /// Identifier to get the required indicator UILabel.
    var requiredIndicatorId: String { return "requiredIndicator" }
}

/// Provide identifiers for clickable input subviews.
public protocol ClickableInputViewIdentifierType: TextInputViewIdentifierType {}

public extension ClickableInputViewIdentifierType {
    
    /// Identifier to get the clickable button.
    var clickableButtonId: String { return "clickableButton" }
}
