//
//  TextInput.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

/// Default TextInputType implementation.
///
/// - `default`: No specialization.
/// - description: Should be multiline. Used for biography information.
/// - email: Email field.
/// - number: Number field. We need to add completion accessory here.
/// - numbersAndPunctuation: Number/Punctuation field.
/// - password: Should be secure input.
public enum TextInput {
    case `default`
    case description
    case email
    case number
    case numbersAndPunctuation
    case password
}

extension TextInput: TextInputType {
    public var isMultiline: Bool {
        switch self {
        case .description:
            return true
            
        default:
            return false
        }
    }
    
    public var keyboardType: UIKeyboardType? {
        switch self {
        case .email:
            return .emailAddress
            
        case .number:
            return .numberPad
            
        case .numbersAndPunctuation:
            return .numbersAndPunctuation
            
        default:
            return .default
        }
    }
    
    public var isSecureInput: Bool {
        switch self {
        case .password:
            return true
            
        default:
            return false
        }
    }
}
