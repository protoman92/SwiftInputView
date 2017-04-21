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
    
    /// Instead of base InputDetailType, we only accept TextInputDetailType.
    ///
    /// - Parameter input: A TextInputDetailType instance.
    public override init<I: TextInputDetailType>(with input: I) {
        super.init(with: input)
    }
    
    override open func builderComponents(for view: UIView)
        -> [ViewBuilderComponentType]
    {
        var components = super.builderComponents(for: view)
        
        if let input = self.input as? TextInputDetailType {
            components.append(normalInput(for: view, using: input))
            components.append(multilineInput(for: view, using: input))
        }
        
        return components
    }
    
    /// Common method to prepare an inputField, since the setup is almost
    /// identical no matter whether the input is multiline or not.
    ///
    /// - Parameters:
    ///   - inputField: The inputField to be prepared.
    ///   - view: The parent UIView.
    ///   - input: An TextInputDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    fileprivate func inputField<I>(_ inputField: I,
                                for view: UIView,
                                using input: TextInputDetailType,
                                dependingOn others: UIView...)
        -> ViewBuilderComponentType
        where I: UIView, I: DynamicFontType
    {
        inputField.accessibilityIdentifier = inputFieldIdentifier
        inputField.fontName = String(describing: 1)
        inputField.fontSize = String(describing: 5)
        
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
    ///   - input: A TextInputDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    open func normalInput(for view: UIView,
                          using input: TextInputDetailType,
                          dependingOn others: UIView...)
        -> ViewBuilderComponentType
    {
        // If multiline input, use UITextView instead.
        if input.isMultilineInput {
            return ViewBuilderComponent.empty
        }
        
        return inputField(BaseTextField(), for: view, using: input)
    }
    
    /// Get a multiline input component i.e. non-multiline. We can use a
    /// PlaceholderTextView for this.
    ///
    /// - Parameters:
    ///   - view: The parent UIView instance.
    ///   - input: A TextInputDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    open func multilineInput(for view: UIView,
                             using input: TextInputDetailType,
                             dependingOn others: UIView...)
        -> ViewBuilderComponentType
    {
        // If not multiline input, use UITextField instead.
        guard input.isMultilineInput else {
            return ViewBuilderComponent.empty
        }
        
        return inputField(PlaceholderTextView(), for: view, using: input)
    }
}

extension TextInputViewBuilder: TextInputViewIdentifierType {}

/// Configure dynamic subviews for text-based InputView.
open class TextInputViewBuilderConfig: InputViewBuilderConfig {
    fileprivate var inputTextColor: UIColor
    
    override init() {
        inputTextColor = .darkGray
        super.init()
    }
    
    override public func configure(for view: UIView) {
        super.configure(for: view)
        let subviews = view.subviews
        
        guard let inputField = subviews.filter({
            $0.accessibilityIdentifier == inputFieldIdentifier
        }).first as? InputFieldType else {
            return
        }
        
        configure(inputField: inputField)
    }
    
    /// Configure an InputFieldType instance.
    ///
    /// - Parameter inputField: An InputFieldType instance.
    fileprivate func configure(inputField: InputFieldType) {
        inputField.textColor = inputTextColor
    }
    
    /// Builder class for TextInputViewBuilderConfig.
    open class TextInputBuilder: BaseBuilder {
        convenience init() {
            self.init(config: TextInputViewBuilderConfig())
        }
        
        var textInputConfig: TextInputViewBuilderConfig? {
            return super.config as? TextInputViewBuilderConfig
        }
        
        /// Set the input field's text color.
        ///
        /// - Parameter color: A UIColor instance.
        /// - Returns: A TextInputBuilder instance.
        public func with(inputTextColor color: UIColor) -> TextInputBuilder {
            textInputConfig?.inputTextColor = color
            return self
        }
    }
}

public extension TextInputViewBuilderConfig {
    
    /// Get a TextInputBuilder instance.
    ///
    /// - Returns: A TextInputBuilder instance.
    public static func textInputBuilder() -> TextInputBuilder {
        return TextInputBuilder()
    }
}

extension TextInputViewBuilderConfig: TextInputViewIdentifierType {}

public protocol TextInputDetailType: InputDetailType {
    
    /// Check whether a UITextField or UITextView is appropriate as the
    /// base input field.
    var isMultilineInput: Bool { get }
}