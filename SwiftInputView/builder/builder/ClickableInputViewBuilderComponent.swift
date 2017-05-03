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
    
    /// Create an Array of UIView for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of UIView.
    override open func subviews(for view: UIView,
                                using input: InputViewDetailType) -> [UIView] {
        var subviews = super.subviews(for: view, using: input)
        subviews.append(button(using: input))
        return subviews
    }
    
    /// Create a UIButton for the current parent subview.
    ///
    /// - Parameter input: An InputViewDetailType instance.
    /// - Returns: A UIButton instance
    open func button(using input: InputViewDetailType) -> UIButton {
        let button = UIBaseButton()
        button.accessibilityIdentifier = clickableButtonId
        return button
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
        
        if let button = subviews.filter({
            $0.accessibilityIdentifier == clickableButtonId
        }).first as? UIButton {
            let cs = self.constraints(forButton: button, for: view)
            allConstraints.append(contentsOf: cs)
        }
        
        return allConstraints
    }
    
    /// Create an Array of NSLayoutConstraint for the clickable button.
    ///
    /// - Parameters:
    ///   - button: A UIButton instance.
    ///   - view: A parent subview instance.
    /// - Returns: An Array of NSLayoutConstraint.
    open func constraints(forButton button: UIButton, for view: UIView)
        -> [NSLayoutConstraint]
    {
        return FitConstraintSet
            .fit(forParent: view, andChild: button)
            .constraints
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
