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
    override open func configureAppearance(forParentSubview view: UIView) {
        super.configureAppearance(forParentSubview: view)
        let subviews = view.subviews
        
        guard
            let inputField = subviews.filter({
                $0.accessibilityIdentifier == inputFieldId
            }).first as? InputFieldType,
            let requiredIndicator = subviews.filter({
                $0.accessibilityIdentifier == requiredIndicatorId
            }).first as? UILabel
        else {
            return
        }
        
        configure(inputField: inputField)
        configure(requiredInput: requiredIndicator)
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
    /// - Parameter inputField: An InputFieldType instance.
    fileprivate func configure(inputField: InputFieldType) {
        inputField.textColor = inputTextColor
        inputField.tintColor = inputTintColor
        inputField.placeholderTextColor = placeholderTextColor
    }
    
    /// Configure required indicator UILabel.
    ///
    /// - Parameter indicator: A UILabel instance.
    fileprivate func configure(requiredInput indicator: UILabel) {
        indicator.text = "input.title.required".localized
        indicator.textColor = requiredIndicatorTextColor
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

extension TextInputViewBuilderConfig: TextInputViewDecoratorType {
    public var textInputDecorator: TextInputViewDecoratorType? {
        return decorator as? TextInputViewDecoratorType
    }
    
    public var requiredIndicatorTextColor: UIColor {
        return textInputDecorator?.requiredIndicatorTextColor ?? .red
    }
    
    public var inputTextColor: UIColor {
        return textInputDecorator?.inputTextColor ?? .darkGray
    }
    
    public var inputTintColor: UIColor {
        return textInputDecorator?.inputTintColor ?? .darkGray
    }
    
    public var placeholderTextColor: UIColor {
        return textInputDecorator?.inputTintColor ?? .lightGray
    }
}

extension TextInputViewBuilderConfig: TextInputViewIdentifierType {}
