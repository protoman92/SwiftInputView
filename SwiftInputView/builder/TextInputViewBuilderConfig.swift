//
//  TextInputViewBuilderConfig.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/23/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftUtilities
import SwiftUIUtilities

/// Configure dynamic subviews for text-based InputView.
open class TextInputViewBuilderConfig: InputViewBuilderConfig {

    /// We override this method to provide individual configurations for
    /// each parent subview.
    override open func configureAppearance(forParentSubview view: UIView,
                                           at index: Int) {
        super.configureAppearance(forParentSubview: view, at: index)
        let subviews = view.subviews
        
        if let inputField = subviews.filter({
            $0.accessibilityIdentifier == inputFieldId
        }).first as? InputFieldType {
            configure(inputField: inputField, at: index)
        }
        
        if let requiredIndicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first as? UILabel {
            configure(requiredInput: requiredIndicator, at: index)
        }
    }
    
    /// Override to provide logic config for text-based inputView.
    override open func configureLogic(forParentSubview view: UIView) {
        super.configureLogic(forParentSubview: view)
        
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
    ///   - index: The index of the parent subview.
    fileprivate func configure(inputField: InputFieldType, at index: Int) {
        inputField.textColor = inputTextColor(for: index)
        inputField.tintColor = inputTintColor(for: index)
        inputField.placeholderTextColor = placeholderTextColor(for: index)
        inputField.textAlignment = inputTextAlignment(for: index)
    }
    
    /// Configure required indicator UILabel.
    ///
    /// - Parameter indicator: A UILabel instance.
    fileprivate func configure(requiredInput indicator: UILabel, at index: Int) {
        indicator.text = "input.title.required".localized
        indicator.textColor = requiredIndicatorTextColor(for: index)
    }
    
    /// Builder class for TextInputViewBuilderConfig.
    open class TextInputBuilder: BaseBuilder {
        convenience init() {
            self.init(config: TextInputViewBuilderConfig())
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

extension TextInputViewBuilderConfig {
    func textInputDecorator(for index: Int) -> TextInputViewDecoratorType? {
        return decorators.element(at: index) as? TextInputViewDecoratorType
    }
    
    /// Get required indicator text color using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A UIColor instance.
    func requiredIndicatorTextColor(for index: Int) -> UIColor {
        let decorator = textInputDecorator(for: index)
        return decorator?.requiredIndicatorTextColor ?? .red
    }
    
    /// Get input text color using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A UIColor instance.
    func inputTextColor(for index: Int) -> UIColor {
        let decorator = textInputDecorator(for: index)
        return decorator?.inputTextColor ?? .darkGray
    }
    
    /// Get input tint color using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A UIColor instance.
    func inputTintColor(for index: Int) -> UIColor {
        let decorator = textInputDecorator(for: index)
        return decorator?.inputTintColor ?? .darkGray
    }
    
    /// Get input text alignment using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A NSTextAlignment instance.
    func inputTextAlignment(for index: Int) -> NSTextAlignment {
        let decorator = textInputDecorator(for: index)
        return decorator?.inputTextAlignment ?? .left
    }
    
    /// Get placeholder text color using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A UIColor instance.
    func placeholderTextColor(for index: Int) -> UIColor {
        let decorator = textInputDecorator(for: index)
        return decorator?.placeholderTextColor ?? .lightGray
    }
}

extension TextInputViewBuilderConfig: TextInputViewIdentifierType {}
