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
        
        let normalInput = self.normalInput(for: view, using: input)
        let multilineInput = self.multilineInput(for: view, using: input)
        
        // We need the get the inputField to pass to required indicator
        // builder since the indicator's top constraint has to be anchored
        // to the inputField's top.
        let indicator = requiredIndicator(
            for: view,
            using: input,
            dependingOn: normalInput, multilineInput
        )
        
        components.append(normalInput)
        components.append(multilineInput)
        components.append(indicator)
        return components
    }
    
    /// Common method to prepare an inputField, since the setup is almost
    /// identical no matter whether the input is multiline or not.
    ///
    /// - Parameters:
    ///   - inputField: The inputField to be prepared.
    ///   - view: The parent UIView.
    ///   - input: An TextInputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance.
    fileprivate func inputField<I>(_ inputField: I,
                                for view: UIView,
                                using input: InputViewDetailType)
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
    /// - Returns: A ViewBuilderComponentType instance.
    open func normalInput(for view: UIView, using input: InputViewDetailType)
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
    /// - Returns: A ViewBuilderComponentType instance.
    open func multilineInput(for view: UIView, using input: InputViewDetailType)
        -> ViewBuilderComponentType
    {
        // If not multiline input, use UITextField instead.
        guard let multiline = input.textInputType?.isMultiline, multiline else {
            return ViewBuilderComponent.empty
        }
        
        return inputField(UIPlaceholderTextView(), for: view, using: input)
    }
    
    /// Return a component for the required indicator.
    ///
    /// - Parameters:
    ///   - view: The parent UIView.
    ///   - input: An InputViewDetailType instance.
    ///   - others: Other ViewBuilderComponentType instances.
    /// - Returns: A ViewBuilderComponentType instance.
    open func requiredIndicator(for view: UIView,
                                using input: InputViewDetailType,
                                dependingOn others: ViewBuilderComponentType...)
        -> ViewBuilderComponentType
    {
        guard
            input.displayRequiredIndicator,
            let inputField = others.flatMap({
                $0.viewToBeAdded as? InputFieldType
            }).first,
            let placeholderView = inputField.placeholderView
        else {
            return ViewBuilderComponent.empty
        }
        
        let indicator = BaseLabel()
        indicator.accessibilityIdentifier = requiredIndicatorId
        indicator.fontName = String(describing: 1)
        indicator.fontSize = String(describing: 3)
        
        // Right constraint.
        let right = BaseLayoutConstraint(item: view,
                                         attribute: .right,
                                         relatedBy: .equal,
                                         toItem: indicator,
                                         attribute: .right,
                                         multiplier: 1,
                                         constant: 0)
        
        right.constantValue = String(describing: 5)
        
        // Vertical constraint. We need to align vertically to the
        // placeholderView so that even if the inputField is multiline (i.e.
        // its height to larger than the rest), the required indicator is
        // still anchored to the centerY of the first line of text.
        let vertical = BaseLayoutConstraint(item: placeholderView,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: indicator,
                                            attribute: .centerY,
                                            multiplier: 1,
                                            constant: 0)
        
        vertical.constantValue = String(describing: 0)
        
        // Return component
        return ViewBuilderComponent.builder()
            .with(view: indicator)
            .add(constraint: right)
            .add(constraint: vertical)
            .build()
    }
}

extension TextInputViewBuilder: TextInputViewIdentifierType {}
