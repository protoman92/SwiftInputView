//
//  InputType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUtilities

/// Implement this protocol on top of InputDetailType to provide information
/// to populate an input view/
public protocol InputViewDetailType: InputDetailType {
    
    /// We can use this input type to supply view information. For e.g., if
    /// this is an instance of TextInputType, we can check the type of
    /// keyboard to be used, or whether the input is multiline.
    var inputType: InputType { get }
    
    /// The input view's width. For e.g., input field for phone extension
    /// should be smaller than others.
    var inputViewWidth: CGFloat? { get }
}

/// Implement this protocol to classify input types. Usually we can use
/// enums for this purpose. E.g. address/email/number etc.
public protocol InputType {}

/// Classify text-based input types.
public protocol TextInputType: InputType {
    
    /// Check whether a UITextField or UITextView is appropriate as the
    /// base input field.
    var isMultiline: Bool { get }
    
    /// Get the keyboard type to use with the input field.
    var keyboardType: UIKeyboardType? { get }
    
    /// Whether the input should be secured e.g. password inputs.
    var isSecureInput: Bool { get }
}

public extension InputViewDetailType {
    
    /// Optionally cast to TextInputType. If we are using a text-based input,
    /// this is expected to be non-nil.
    public var textInputType: TextInputType? {
        return inputType as? TextInputType
    }
}
