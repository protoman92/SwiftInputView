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
    
    // MARK: ViewBuilderType
    
    /// Get an Array of ViewBuilderComponentType, using an InputViewDetailType
    /// and an InputViewDecoratorType instance.
    ///
    /// - Parameters input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType instances.
    override open func builderComponents(using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        var components = super.builderComponents(using: input)
        components.append(normalInput(using: input))
        components.append(multilineInput(using: input))
        components.append(requiredIndicator(using: input))
        return components
    }
    
    /// Create an Array of NSLayoutConstraint to be used with the inputField.
    ///
    /// - Parameters:
    ///   - view: The parent subview instance.
    ///   - inputField: An optional InputFieldType instance. This is because
    ///                 this function will be called within a closure.
    ///   - current: The current TextInputViewBuilderComponent instance.
    /// - Returns: An Array of NSLayoutConstraint.
    func inputFieldConstraints<I>(for view: UIView,
                               for inputField: I?,
                               with current: TextInputViewBuilderComponent?)
        -> [NSLayoutConstraint]
        where I: UIView, I: InputFieldType
    {
        guard let inputField = inputField else { return [] }
        
        return FitConstraintSet.builder()
            .with(parent: view)
            .with(child: inputField)
            .add(left: true, withMargin: Space.medium.value)
            .add(top: true)
            .add(bottom: true)
            .add(right: true)
            .build()
            .constraints
    }
    
    /// Common method to prepare an inputField, since the setup is almost
    /// identical no matter whether the input is multiline or not.
    ///
    /// - Parameters:
    ///   - inputField: The inputField to be prepared.
    ///   - input: An TextInputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance.
    func inputField<I>(_ inputField: I, using input: InputViewDetailType)
        -> ViewBuilderComponentType
        where I: UIView, I: DynamicFontType & InputFieldType
    {
        inputField.accessibilityIdentifier = inputFieldId
        
        let closure: (UIView) -> [NSLayoutConstraint] = {
            [weak self, weak inputField] in
            return self?.inputFieldConstraints(for: $0,
                                               for: inputField,
                                               with: self) ?? []
        }
        
        return ViewBuilderComponent.builder()
            .with(view: inputField)
            .with(closure: closure)
            .build()
    }
    
    /// Get a normal input component i.e. non-multiline. We can use a
    /// UITextField for this.
    ///
    /// - Parameters input: A TextInputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance.
    open func normalInput(using input: InputViewDetailType)
        -> ViewBuilderComponentType
    {
        // If multiline input, use UITextView instead.
        if let multiline = input.textInputType?.isMultiline, multiline {
            return ViewBuilderComponent.empty
        }
        
        return inputField(UIReactiveTextField(), using: input)
    }
    
    /// Get a multiline input component i.e. non-multiline. We can use a
    /// PlaceholderTextView for this.
    ///
    /// - Parameters input: A TextInputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance.
    open func multilineInput(using input: InputViewDetailType)
        -> ViewBuilderComponentType
    {
        // If not multiline input, use UITextField instead.
        guard let multiline = input.textInputType?.isMultiline, multiline else {
            return ViewBuilderComponent.empty
        }
        
        return inputField(UIPlaceholderTextView(), using: input)
    }
    
    /// Create a label to be used a the required indicator.
    ///
    /// - Returns: A UILabel instance.
    open func requiredIndicator() -> UILabel { return UIBaseLabel() }
    
    /// Create an Array of NSLayoutConstraint for the required indicator.
    ///
    /// - Parameters:
    ///   - view: The parent subview instance.
    ///   - indicator: An optional UILabel instance. This is because this
    ///                function will be called in a closure.
    ///   - current: The current TextInputViewBuilderComponent instance.
    /// - Returns: An Array of NSLayoutConstraint.
    open func requiredIndicatorConstraints(
        for view: UIView,
        for indicator: UILabel?,
        with current: TextInputViewBuilderComponent?
    ) -> [NSLayoutConstraint] {
        guard
            let current = current,
            let indicator = indicator,
            let inputField = view.subviews.filter({
                $0.accessibilityIdentifier == current.inputFieldId
            }).first as? InputFieldType,
            let placeholderView = inputField.placeholderView
        else {
            debugException()
            return []
        }
        
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
        
        return [right, vertical]
    }
    
    /// Return a component for the required indicator.
    ///
    /// - Parameters:
    ///   - view: The parent UIView.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance.
    open func requiredIndicator(using input: InputViewDetailType)
        -> ViewBuilderComponentType
    {
        let indicator = requiredIndicator()
        
        indicator.accessibilityIdentifier = requiredIndicatorId
        
        let closure: (UIView) -> [NSLayoutConstraint] = {
            [weak self, weak indicator] in
            return self?.requiredIndicatorConstraints(for: $0,
                                                      for: indicator,
                                                      with: self) ?? []
        }
        
        // Return component
        return ViewBuilderComponent.builder()
            .with(view: indicator)
            .with(closure: closure)
            .build()
    }
    
    // MARK: ViewBuilderConfigType
    
    /// This method only configures the view's appearance.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    ///   - decorator: An InputViewDecoratorType instance.
    override open func configureAppearance(for view: UIView,
                                           using input: InputViewDetailType,
                                           using decorator: InputViewDecoratorType) {
        super.configureAppearance(for: view, using: input, using: decorator)
        
        let subviews = view.subviews
        
        if let inputField = subviews.filter({
            $0.accessibilityIdentifier == inputFieldId
        }).first as? InputFieldType {
            configure(inputField: inputField, using: input, using: self)
        }
        
        if let indicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first as? UILabel {
            configure(requiredIndicator: indicator, using: input, using: self)
        }
    }
    
    /// Configure business logic for a parent subview, or the master view if
    /// there is only one input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    override open func configureLogic(for view: UIView,
                                      using input: InputViewDetailType) {
        super.configureLogic(for: view, using: input)
        
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
    ///   - input: An InputViewDetailType instance.
    ///   - decorator: A TextInputViewDecoratorType instance.
    func configure(inputField: InputFieldType,
                   using inputs: InputViewDetailType,
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
    ///   - input: An InputViewDetailType instance.
    ///   - decorator: A TextInputViewDecoratorType instance.
    func configure(requiredIndicator indicator: UILabel,
                   using inputs: InputViewDetailType,
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
