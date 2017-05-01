//
//  InputViewBuilderComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import SwiftUtilities

/// Implement this protocol to build for each input, i.e. Each 
/// InputViewBuilderType (which contains an Array of InputViewDetailType)
/// will execute a series of InputViewBuilderComponentType to set up each
/// InputViewDetailType.
///
/// Using this strategy, even if an input view has multiple inputs, each of
/// those inputs will still be individually configured. For e.g., we can
/// put a choice input and a text input in the same master view.
public protocol InputViewBuilderComponentType: ViewBuilderType {
    init(with: InputViewDetailType)
    
    var input: InputViewDetailType { get }
    
    /// This decorator should be acquired from the input itself.
    var decorator: InputViewDecoratorType { get }
    
    /// Create an Array of UIView for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of UIView.
    func subviews(for view: UIView, using input: InputViewDetailType) -> [UIView]
    
    /// Create an Array of NSLayoutConstraint for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of NSLayoutConstraint.
    func constraints(for view: UIView, using input: InputViewDetailType)
        -> [NSLayoutConstraint]
}

/// The default component builder class whenever InputViewBuilderComponentType
/// is required.
open class InputViewBuilderComponent {
    public let input: InputViewDetailType
    public let decorator: InputViewDecoratorType
    
    public required init(with input: InputViewDetailType) {
        self.input = input
        self.decorator = input.decorator
    }
    
    // MARK: ViewBuilderType.
    
    /// Get an Array of UIView subviews to be added to a UIView.
    /// - Parameter view: The parent UIView instance.
    /// - Returns: An Array of ViewBuilderComponentType.
    open func subviews(for view: UIView) -> [UIView] {
        return subviews(for: view, using: input)
    }
    
    /// Create an Array of UIView for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of UIView.
    open func subviews(for view: UIView, using input: InputViewDetailType)
        -> [UIView]
    {
        return []
    }
    
    /// Get an Array of NSLayoutConstraint to be added to a UIView.
    ///
    /// - Parameter view: The parent UIView instance.
    /// - Returns: An Array of NSLayoutConstraint.
    open func constraints(for view: UIView) -> [NSLayoutConstraint] {
        return constraints(for: view, using: input)
    }
    
    /// Create an Array of NSLayoutConstraint for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of NSLayoutConstraint.
    open func constraints(for view: UIView, using input: InputViewDetailType)
        -> [NSLayoutConstraint]
    {
        return []
    }
    
    // MARK: ViewBuilderConfigType.
    
    open func configure(for view: UIView) {
        configure(appearanceFor: view, using: input, using: self)
        configure(logicFor: view, using: input)
    }
    
    /// This method only configures the view's appearance.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    ///   - decorator: An InputViewDecoratorType instance.
    open func configure(appearanceFor view: UIView,
                        using input: InputViewDetailType,
                        using decorator: InputViewDecoratorType) {
        view.backgroundColor = decorator.inputBackgroundColor
        view.layer.cornerRadius = decorator.inputCornerRadius ?? 0
    }
    
    /// Configure business logic for a parent subview, or the master view if
    /// there is only one input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    open func configure(logicFor view: UIView, using input: InputViewDetailType) {
        if let view = view as? TextInputViewComponentType {
            // We setup the inputField here, e.g. wire up text listeners.
            view.setupInputField()
        }
    }
}

extension InputViewBuilderComponent: InputViewIdentifierType {}

extension InputViewBuilderComponent: InputViewDecoratorType {
    public var horizontalSpacing: CGFloat {
        return (decorator.horizontalSpacing ?? Space.smaller.value) ?? 0
    }
    
    public var inputCornerRadius: CGFloat {
        return (decorator.inputCornerRadius ?? Space.small.value) ?? 0
    }
    
    public var inputBackgroundColor: UIColor {
        return decorator.inputBackgroundColor ?? .clear
    }
}

extension InputViewBuilderComponent: InputViewBuilderComponentType {}
