//
//  TextInputViewBuilder.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import SwiftUtilities
import SwiftPlaceholderTextView
import UIKit

/// Use this builder class for text-based inputs.
open class TextInputViewBuilder: InputViewBuilder {
    
    override open func builderComponents(forParentSubview view: UIView,
                                         using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        var components = super.builderComponents(forParentSubview: view,
                                                 using: input)
        
        components.append(normalInput(for: view, using: input))
        components.append(multilineInput(for: view, using: input))
        return components
    }
    
    /// Common method to prepare an inputField, since the setup is almost
    /// identical no matter whether the input is multiline or not.
    ///
    /// - Parameters:
    ///   - inputField: The inputField to be prepared.
    ///   - view: The parent UIView.
    ///   - input: An TextInputViewDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    fileprivate func inputField<I>(_ inputField: I,
                                for view: UIView,
                                using input: InputViewDetailType,
                                dependingOn others: UIView...)
        -> ViewBuilderComponentType
        where I: UIView, I: DynamicFontType & InputFieldType
    {
        inputField.accessibilityIdentifier = inputFieldId
        inputField.fontName = String(describing: 1)
        inputField.fontSize = String(describing: 5)
        
        if let textInput = input as? TextInputViewDetailType {
            inputField.placeholder = textInput.placeholder
        }
        
        // Add constraints to fit.
        let constraints = FitConstraintSet.builder()
            .with(parent: view)
            .with(child: inputField)
            .add(left: true, withMargin: Space.medium.value)
            .add(top: true)
            .add(bottom: true)
            .add(right: true)
            .build()
            .constraints
        
        return ViewBuilderComponent.builder()
            .with(view: inputField)
            .with(constraints: constraints)
            .build()
    }
    
    /// Get a normal input component i.e. non-multiline. We can use a 
    /// UITextField for this.
    ///
    /// - Parameters:
    ///   - view: The parent UIView instance.
    ///   - input: A TextInputViewDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    open func normalInput(for view: UIView,
                          using input: InputViewDetailType,
                          dependingOn others: UIView...)
        -> ViewBuilderComponentType
    {
        // If multiline input, use UITextView instead.
        if let multiline = input.textInputType?.isMultiline, multiline {
            return ViewBuilderComponent.empty
        }
        
        return inputField(BaseTextField(), for: view, using: input)
    }
    
    /// Get a multiline input component i.e. non-multiline. We can use a
    /// PlaceholderTextView for this.
    ///
    /// - Parameters:
    ///   - view: The parent UIView instance.
    ///   - input: A TextInputViewDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    open func multilineInput(for view: UIView,
                             using input: InputViewDetailType,
                             dependingOn others: UIView...)
        -> ViewBuilderComponentType
    {
        // If not multiline input, use UITextField instead.
        guard let multiline = input.textInputType?.isMultiline, multiline else {
            return ViewBuilderComponent.empty
        }
        
        return inputField(UIPlaceholderTextView(), for: view, using: input)
    }
}

extension TextInputViewBuilder: TextInputViewIdentifierType {}
