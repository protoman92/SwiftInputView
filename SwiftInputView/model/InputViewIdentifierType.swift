//
//  InputViewIdentifierType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Provide identifiers for input subviews.
public protocol InputViewIdentifierType {}

public extension InputViewIdentifierType {
    
    /// Identifier to get parent subviews.
    var parentSubviewIdentifier: String {
        return "parentSubview"
    }
    
    /// Identifier to get the required indicator UILabel.
    var requiredIndicatorIdentifier: String {
        return "requiredIndicator"
    }
    
    /// In case there are multiple inputs in one input view, we want to keep
    /// separate accessibility identifiers.
    ///
    /// - Parameter index: The index corresponding to the input's index.
    /// - Returns: A String value.
    func parentSubviewIdentifier(for index: Int) -> String {
        return "\(parentSubviewIdentifier)\(index)"
    }
}

/// Provide identifiers for text input subviews.
public protocol TextInputViewIdentifierType: InputViewIdentifierType {}

public extension TextInputViewIdentifierType {
    
    /// Identifier to get the input field.
    var inputFieldIdentifier: String {
        return "inputField"
    }
}
