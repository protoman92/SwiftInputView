//
//  InputType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUtilities
import SwiftUIUtilities

/// Implement this protocol on top of InputDetailType to provide information
/// to populate an input view.
///
/// The default builder class we are using is InputViewBuilder, and the config 
/// class should be InputViewBuilderConfig.
public protocol InputViewDetailType: InputDetailType {
    
    /// Get a InputViewBuilderComponentType type to dynamically construct a
    /// InputViewBuilderComponentType instance. Use a default type if this
    /// is nil.
    var viewBuilderComponentType: InputViewBuilderComponentType.Type? { get }
    
    /// We can use this input type to supply view information. For e.g., if
    /// this is an instance of TextInputType, we can check the type of
    /// keyboard to be used, or whether the input is multiline.
    var inputType: InputType { get }
    
    /// Check if required indicator should be displayed, even if the input
    /// is required - e.g. when an explicit input width is specified and it
    /// is not large enough to display the required indicator text. This value
    /// is required here instead of in a decorator because we need it to
    /// determine whether to construct the required indicator in the first
    /// place.
    var shouldDisplayRequiredIndicator: Bool { get }
    
    /// Get a decorator instance to pass to config phase. Instead of asking
    /// this type to implement InputViewDecoratorType, we can use this to
    /// allow optional properties for the decorators (since we will most
    /// likely be using enums for InputViewDetailType, which are not objc
    /// compliant).
    var decorator: InputViewDecoratorType { get }
    
    /// The input view's width. For e.g., input field for phone extension
    /// should be smaller than others. We ask for inputWidth here because
    /// this value will be used during view building phase (since we need to
    /// create constraints).
    ///
    /// Return nil to use default value (i.e. multiplier ratio constraint
    /// instead of concrete width constraint)
    var inputWidth: CGFloat? { get }
    
    /// The input view's height. Return nil to use default value (i.e.
    /// textInputType.suggestedInputHeight).
    var inputHeight: CGFloat? { get }
    
    /// Get the placeholder text for this input.
    var placeholder: String? { get }
}

public extension InputViewDetailType {
    
    /// Only display required indicator if both conditions pass.
    public var displayRequiredIndicator: Bool {
        return isRequired && shouldDisplayRequiredIndicator
    }
    
    /// Create a InputViewBuilderComponentType instance.
    ///
    /// - Returns: An InputViewBuilderComponentType instance.
    public func viewBuilderComponent() -> InputViewBuilderComponentType {
        let type = viewBuilderComponentType ?? TextInputViewBuilderComponent.self
        return type.init(with: self)
    }
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

public extension TextInputType {
    
    /// Get the suggested height for an input. For e.g. multiline inputs
    /// should be larger than the rest.
    public var suggestedInputHeight: CGFloat? {
        return (isMultiline ? Size.huge : .medium).value
    }
}

public extension InputViewDetailType {
    
    /// Optionally cast to TextInputType. If we are using a text-based input,
    /// this is expected to be non-nil.
    public var textInputType: TextInputType? {
        return inputType as? TextInputType
    }
}

public extension Sequence where Iterator.Element == InputViewDetailType {
    
    /// Get the largest height in a Sequence of InputViewDetailType.
    public var largestHeight: CGFloat {
        return flatMap({
            $0.inputHeight ?? $0.textInputType?.suggestedInputHeight
        }).max() ?? 0
    }
}

public extension Sequence where Iterator.Element: InputViewDetailType {
    
    /// Get the largest height in a Sequence of InputViewDetailType. We need
    /// to cast each element to InputViewDetailType, and then use the
    /// resulting Sequence's largestHeight property.
    public var largestHeight: CGFloat {
        return map({$0 as InputViewDetailType}).largestHeight
    }
}
