//
//  TextInputViewConfigComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUtilities
import SwiftUIUtilities

/// Configure text-based inputs.
open class TextInputViewConfigComponent: InputViewConfigComponent {
    override open func configureAppearance(for view: UIView) {
        super.configureAppearance(for: view)
        let subviews = view.subviews
        
        if let inputField = subviews.filter({
            $0.accessibilityIdentifier == inputFieldId
        }).first as? InputFieldType {
            configure(inputField: inputField)
        }
        
        if let requiredIndicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first as? UILabel {
            configure(requiredInput: requiredIndicator)
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
    /// - Parameters inputField: An InputFieldType instance.
    fileprivate func configure(inputField: InputFieldType) {
        inputField.autocorrectionType = .no
        inputField.textColor = inputTextColor
        inputField.textAlignment = inputTextAlignment
        inputField.tintColor = inputTintColor
        inputField.placeholderTextColor = placeholderTextColor
    }
    
    /// Configure required indicator UILabel.
    ///
    /// - Parameter indicator: A UILabel instance.
    fileprivate func configure(requiredInput indicator: UILabel) {
        indicator.text = requiredIndicatorText
        indicator.textColor = requiredIndicatorTextColor
    }
}

extension TextInputViewConfigComponent: TextInputViewIdentifierType {}

extension TextInputViewConfigComponent {
    
    fileprivate var textDecorator: TextInputViewDecoratorType? {
        return decorator as? TextInputViewDecoratorType
    }
    
    public var isSecureTextEntry: Bool {
        return textDecorator?.isSecureTextEntry ?? false
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

extension TextInputViewConfigComponent: TextInputViewDecoratorType {}
