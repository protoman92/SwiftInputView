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
    
    /// Create an Array of ViewBuilderComponentType for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType.
    func builderComponents(using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
}

open class InputViewBuilderComponent {
    public let input: InputViewDetailType
    public let decorator: InputViewDecoratorType
    
    public required init(with input: InputViewDetailType) {
        self.input = input
        self.decorator = input.decorator
    }
    
    // MARK: ViewBuilderType.

    /// Get an Array of ViewBuilderComponentType, using an InputViewDetailType
    /// and an InputViewDecoratorType instance.
    ///
    /// - Parameters input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType instances.
    open func builderComponents(using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        return []
    }
    
    // MARK: ViewBuilderConfigType.
    
    open func configure(for view: UIView) {
        configureAppearance(for: view, using: input, using: self)
        configureLogic(for: view, using: input)
    }
    
    /// This method only configures the view's appearance.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    ///   - decorator: An InputViewDecoratorType instance.
    open func configureAppearance(for view: UIView,
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
    open func configureLogic(for view: UIView, using input: InputViewDetailType) {
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

extension InputViewBuilderComponent: InputViewBuilderComponentType {
    
    /// Create an Array of ViewBuilderComponentType for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType.
    open func builderComponents() -> [ViewBuilderComponentType] {
        return builderComponents(using: input)
    }
}
