//
//  TextInputViewBuilderComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftBaseViews
import SwiftPlaceholderTextView
import SwiftReactiveTextField
import SwiftUtilities
import SwiftUIUtilities

/// Handle text-based inputs.
open class TextInputViewBuilderComponent: InputViewBuilderComponent {
    
    /// Get an Array of ViewBuilderComponentType, using an InputViewDetailType
    /// and an InputViewDecoratorType instance.
    ///
    /// - Parameters:
    ///   - view: The parent subview instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType instances.
    override open func builderComponents(for view: UIView,
                                         using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        var components = super.builderComponents(for: view, using: input)
        let normalInput = self.normalInput(for: view, using: input)
        let multilineInput = self.multilineInput(for: view, using: input)
        
        // We need the get the inputField to pass to required indicator
        // builder since the indicator's top constraint has to be anchored
        // to the inputField's top.
        let indicator = requiredIndicator(
            for: view,
            using: input,
            using: self,
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
    func inputField<I>(_ inputField: I,
                    for view: UIView,
                    using input: InputViewDetailType)
        -> ViewBuilderComponentType
        where I: UIView, I: DynamicFontType & InputFieldType
    {
        inputField.accessibilityIdentifier = inputFieldId
        
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
        
        return inputField(UIReactiveTextField(), for: view, using: input)
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
                                using decorator: TextInputViewDecoratorType,
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
        
        let indicator = UIBaseLabel()
        
        indicator.accessibilityIdentifier = requiredIndicatorId
        
        // Right constraint.
        let right = NSBaseLayoutConstraint(item: view,
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
        let vertical = NSBaseLayoutConstraint(item: placeholderView,
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

extension TextInputViewBuilderComponent {
    override open func configureAppearance(for view: UIView) {
        super.configureAppearance(for: view)
        let subviews = view.subviews
        
        if let inputField = subviews.filter({
            $0.accessibilityIdentifier == inputFieldId
        }).first as? InputFieldType {
            configure(inputField: inputField, using: self)
        }
        
        if let requiredIndicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first as? UILabel {
            configure(requiredIndicator: requiredIndicator, using: self)
        }
    }
    
    override open func configureLogic(for view: UIView) {
        super.configureLogic(for: view)
        
        guard let view = view as? TextInputViewComponentType else {
            return
        }
        
        // We setup the inputField here, e.g. wire up text listeners.
        view.setupInputField()
    }
    
    /// Configure an InputFieldType instance.
    ///
    /// - Parameters:
    ///   - inputField: An InputFieldType instance.
    ///   - decorator: A TextInputViewDecoratorType instance.
    fileprivate func configure(inputField: InputFieldType,
                               using decorator: TextInputViewDecoratorType) {
        inputField.autocorrectionType = .no
        inputField.placeholder = input.placeholder
        inputField.textColor = decorator.inputTextColor
        inputField.textAlignment = decorator.inputTextAlignment ?? .natural
        inputField.tintColor = decorator.inputTintColor
        inputField.placeholderTextColor = decorator.placeholderTextColor
        inputField.font = decorator.inputFieldFont
        
        if let textInput = input.textInputType {
            inputField.isSecureTextEntry = textInput.isSecureInput
            inputField.keyboardType = textInput.keyboardType ?? .default
        }
    }
    
    /// Configure required indicator UILabel.
    ///
    /// - Parameters:
    ///   - indicator: A UILabel instance.
    ///   - decorator: A TextInputViewDecoratorType instance.
    fileprivate func configure(requiredIndicator indicator: UILabel,
                               using decorator: TextInputViewDecoratorType) {
        indicator.text = decorator.requiredIndicatorText
        indicator.textColor = decorator.requiredIndicatorTextColor
        indicator.font = decorator.requiredIndicatorFont
    }
}

extension TextInputViewBuilderComponent: TextInputViewIdentifierType {}

extension TextInputViewBuilderComponent: TextInputViewDecoratorType {
    fileprivate var textDecorator: TextInputViewDecoratorType? {
        return decorator as? TextInputViewDecoratorType
    }
    
    public var inputFieldFontName: String {
        return textDecorator?.inputFieldFontName ?? ""
    }
    
    public var inputFieldFontSize: CGFloat {
        return textDecorator?.inputFieldFontSize ?? 0
    }
    
    public var requiredIndicatorFontName: String {
        return textDecorator?.requiredIndicatorFontName ?? ""
    }
    
    public var requiredIndicatorFontSize: CGFloat {
        return textDecorator?.requiredIndicatorFontSize ?? 0
    }
    
    public var requiredIndicatorTextColor: UIColor {
        return textDecorator?.requiredIndicatorTextColor ?? .red
    }
    
    public var requiredIndicatorText: String {
        return textDecorator?.requiredIndicatorText ?? "input.title.required"
    }
    
    public var inputTextColor: UIColor {
        return textDecorator?.inputTextColor ?? .darkGray
    }
    
    public var inputTintColor: UIColor {
        return textDecorator?.inputTintColor ?? .darkGray
    }
    
    public var inputTextAlignment: NSTextAlignment {
        return textDecorator?.inputTextAlignment ?? .left
    }
    
    public var placeholderTextColor: UIColor {
        return textDecorator?.placeholderTextColor ?? .lightGray
    }
}
