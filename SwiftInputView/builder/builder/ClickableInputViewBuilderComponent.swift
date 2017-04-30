//
//  ClickableInputViewBuilderComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/27/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftBaseViews
import SwiftUIUtilities
import UIKit

/// Use this component to construct clickable inputs, e.g. choice-based whereby
/// a dialog of choices are displayed once the user clicks on the input view.
open class ClickableInputViewBuilderComponent: TextInputViewBuilderComponent {
    
    // MARK: ViewBuilderType
    
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
        components.append(button(for: view, using: input))
        return components
    }
    
    /// Create a UIButton for the current parent subview.
    ///
    /// - Parameters:
    ///   - view: A parent subview instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance
    open func button(for view: UIView, using input: InputViewDetailType)
        -> ViewBuilderComponentType
    {
        let button = UIBaseButton()
        
        button.accessibilityIdentifier = clickableButtonId
        
        let constraints = FitConstraintSet
            .fit(forParent: view, andChild: button)
            .constraints
        
        return ViewBuilderComponent.builder()
            .with(view: button)
            .with(constraints: constraints)
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
        
        if let button = subviews.filter({
            $0.accessibilityIdentifier == clickableButtonId
        }).first as? UIButton {
            configure(button: button, using: input, using: self)
        }
    }
    
    /// Configure the clickable button.
    ///
    /// - Parameter button: A UIButton instance.
    open func configure(button: UIButton,
                        using input: InputViewDetailType,
                        using decorator: ClickableInputViewDecoratorType) {
        button.backgroundColor = .clear
        button.titleLabel?.textColor = .clear
        button.titleLabel?.font = decorator.buttonFont
    }
}

extension ClickableInputViewBuilderComponent: ClickableInputViewDecoratorType {
    
    /// Optionally cast the decorator to ClickableInputViewDecoratorType.
    var clickableDecorator: ClickableInputViewDecoratorType? {
        return decorator as? ClickableInputViewDecoratorType
    }
    
    public var buttonFontName: String {
        return clickableDecorator?.buttonFontName ?? DefaultFont.normal.value
    }
    
    public var buttonFontSize: CGFloat {
        return clickableDecorator?.buttonFontSize ?? TextSize.medium.value ?? 0
    }
}

extension ClickableInputViewBuilderComponent: ClickableInputViewIdentifierType {}
