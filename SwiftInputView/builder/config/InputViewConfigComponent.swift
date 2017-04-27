//
//  InputViewConfigComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUtilities
import SwiftUIUtilities

/// Implement this protocol to config for each input, i.e. Each
/// InputViewConfigType (which contains an Array of InputViewDecoratorType)
/// will execute a series of InputViewConfigComponentType to set up each
/// InputViewDetailType.
///
/// Using this strategy, even if an input view has multiple inputs, each of
/// those inputs will still be individually configured. For e.g., we can
/// put a choice input and a text input in the same master view.
@objc public protocol InputViewConfigComponentType: ViewBuilderConfigType {
    init(with decorator: InputViewDecoratorType)
    
    var decorator: InputViewDecoratorType { get }
}

open class InputViewConfigComponent {
    
    /// Use this decorator to provide appearance configurations.
    public let decorator: InputViewDecoratorType
    
    @objc public required init(with decorator: InputViewDecoratorType) {
        self.decorator = decorator
    }
    
    open func configure(for view: UIView) {
        configureAppearance(for: view)
        configureLogic(for: view)
    }
    
    /// This method only configures the view's appearance.
    ///
    /// - Parameters view: A UIView instance.
    open func configureAppearance(for view: UIView) {
        view.backgroundColor = inputBackgroundColor
        view.layer.cornerRadius = inputCornerRadius
    }
    
    /// Configure business logic for a parent subview, or the master view if
    /// there is only one input.
    ///
    /// - Parameter view: A UIView instance.
    open func configureLogic(for view: UIView) {}
}

extension InputViewConfigComponent: InputViewIdentifierType {}
extension InputViewConfigComponent: InputViewConfigComponentType {}

extension InputViewConfigComponent: InputViewDecoratorType {
    
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
