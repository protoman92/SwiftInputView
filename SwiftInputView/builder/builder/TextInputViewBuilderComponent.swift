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
    
    /// Create an Array of UIView for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of UIView.
    override open func subviews(for view: UIView, using input: InputViewDetailType)
        -> [UIView]
    {
        var subviews = super.subviews(for: view, using: input)
        
        if let indicator = requiredIndicator(using: input) {
            subviews.append(indicator)
        }
        
        subviews.append(inputField(using: input))
        return subviews
    }
    
    /// Create a label to be used as the required indicator.
    ///
    /// - Parameters input: An InputViewDetailType instance.
    /// - Returns: An optional UILabel instance. If 
    ///            input.displayRequiredIndicator returns false, we do not
    ///            attach any view.
    open func requiredIndicator(using: InputViewDetailType) -> UILabel? {
        if input.displayRequiredIndicator {
            let indicator = UIBaseLabel()
            indicator.accessibilityIdentifier = requiredIndicatorId
            return indicator
        } else {
            return nil
        }
    }
    
    /// Create a InputFieldType to be used as the main input field.
    ///
    /// - Parameters input: An InputViewDetailType instance.
    /// - Returns: A UIView instance.
    open func inputField(using input: InputViewDetailType) -> UIView {
        let inputField: UIView
        
        if let inputType = input.textInputType, inputType.isMultiline {
            inputField = UIPlaceholderTextView()
        } else {
            inputField = UIReactiveTextField()
        }
        
        inputField.accessibilityIdentifier = inputFieldId
        return inputField
    }
    
    /// Create an Array of NSLayoutConstraint for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of NSLayoutConstraint.
    override open func constraints(for view: UIView,
                                   using input: InputViewDetailType)
        -> [NSLayoutConstraint]
    {
        var allConstraints = super.constraints(for: view, using: input)
        
        let subviews = view.subviews
        
        if let inputField = subviews.filter({
            $0.accessibilityIdentifier == inputFieldId
        }).first {
            let cs = self.constraints(forInputField: inputField, for: view)
            allConstraints.append(contentsOf: cs)
        }
        
        if let indicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first {
            let cs = self.constraints(forRequiredIndicator: indicator, for: view)
            allConstraints.append(contentsOf: cs)
        }
        
        return allConstraints
    }
    
    /// Create an Array of NSLayoutConstraint to be used with the inputField.
    ///
    /// - Parameters:
    ///   - inputField: An InputFieldType instance.
    ///   - view: The parent subview instance.
    ///   - current: The current TextInputViewBuilderComponent instance.
    /// - Returns: An Array of NSLayoutConstraint.
    func constraints(forInputField inputField: UIView, for view: UIView)
        -> [NSLayoutConstraint]
    {
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
    
    /// Create an Array of NSLayoutConstraint for the required indicator.
    ///
    /// - Parameters:
    ///   - indicator: An UIView instance.
    ///   - view: The parent subview instance.
    /// - Returns: An Array of NSLayoutConstraint.
    open func constraints(forRequiredIndicator indicator: UIView, for view: UIView)
        -> [NSLayoutConstraint]
    {
        guard
            let inputField = view.subviews.filter({
                $0.accessibilityIdentifier == inputFieldId
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
    
    // MARK: ViewBuilderConfigType
    
    /// This method only configures the view's appearance.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    ///   - decorator: An InputViewDecoratorType instance.
    override open func configure(appearanceFor view: UIView,
                                 using input: InputViewDetailType,
                                 using decorator: InputViewDecoratorType) {
        super.configure(appearanceFor: view, using: input, using: decorator)
        
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
    override open func configure(logicFor view: UIView,
                                 using input: InputViewDetailType) {
        super.configure(logicFor: view, using: input)
        
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
