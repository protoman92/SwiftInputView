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
    
    /// Identifier to get the required indicator UILabel.
    var requiredIndicatorIdentifier: String {
        return "requiredIndicator"
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
