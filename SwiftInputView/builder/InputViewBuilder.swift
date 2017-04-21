//
//  InputViewBuilder.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUtilities
import SwiftUIUtilities

/// Protocol for input view builder.
public protocol InputViewBuilderType: ViewBuilderType {
    var input: InputDetailType { get }
}

/// Base class for building InputView.
open class InputViewBuilder {
    
    /// Use this InputDetailType to construct builder components.
    open let input: InputDetailType
    
    /// We are not using Builder with this class since we expect subclasses
    /// to accept only one argument.
    ///
    /// - Parameter input: An InputDetailType instance.
    public init<I: InputDetailType>(with input: I) {
        self.input = input
    }
    
    open func builderComponents(for view: UIView) -> [ViewBuilderComponentType] {
        let indicator = requiredIndicator(for: view, using: input)
        return [indicator]
    }

    /// Return a component for the required indicator.
    ///
    /// - Parameters:
    ///   - view: The parent UIView.
    ///   - input: An InputDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    open func requiredIndicator(for view: UIView,
                                using input: InputDetailType,
                                dependingOn others: UIView...)
        -> ViewBuilderComponentType
    {
        if !input.isRequired {
            return ViewBuilderComponent.empty
        }
        
        let indicator = BaseLabel()
        indicator.accessibilityIdentifier = requiredIndicatorIdentifier
        indicator.fontName = String(describing: 1)
        indicator.fontSize = String(describing: 3)
        
        // Right constraint.
        let rightConstraint = BaseLayoutConstraint(item: view,
                                                   attribute: .right,
                                                   relatedBy: .equal,
                                                   toItem: indicator,
                                                   attribute: .right,
                                                   multiplier: 1,
                                                   constant: 0)
        
        rightConstraint.constantValue = String(describing: 5)
        
        // Vertical constraint
        let verticalConstraint = BaseLayoutConstraint(item: view,
                                                      attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: indicator,
                                                      attribute: .centerY,
                                                      multiplier: 1,
                                                      constant: 0)
        
        verticalConstraint.constantValue = String(describing: 0)
        
        // Return component
        return ViewBuilderComponent.builder()
            .with(view: indicator)
            .add(constraint: rightConstraint)
            .add(constraint: verticalConstraint)
            .build()
    }
}

extension InputViewBuilder: InputViewIdentifierType {}

extension InputViewBuilder: InputViewBuilderType {}

/// Configure dynamic subviews for InputView.
open class InputViewBuilderConfig {
    fileprivate var requiredIndicatorTextColor: UIColor
    
    init() {
        requiredIndicatorTextColor = .red
    }
    
    public func configure(for view: UIView) {
        let subviews = view.subviews
        
        guard let requiredIndicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorIdentifier
        }).first as? UILabel else {
            return
        }
        
        configure(requiredInput: requiredIndicator)
    }
    
    /// Configure required indicator UILabel.
    ///
    /// - Parameter indicator: A UILabel instance.
    fileprivate func configure(requiredInput indicator: UILabel) {
        indicator.text = "input.title.required".localized
        indicator.textColor = requiredIndicatorTextColor
    }
    
    /// Builder class for InputViewBuilderConfig.
    open class BaseBuilder {
        let config: InputViewBuilderConfig
        
        /// Initialize with a InputViewBuilderConfig object. This allows
        /// subclasses to provide their own config instance.
        ///
        /// - Parameter config: An InputViewBuilderConfig instance.
        init(config: InputViewBuilderConfig) {
            self.config = config
        }
        
        convenience init() {
            self.init(config: InputViewBuilderConfig())
        }
        
        /// Set the required indicator's text color.
        ///
        /// - Parameter color: A UIColor instance.
        /// - Returns: The current Builder instance.
        public func with(requiredIndicatorTextColor color: UIColor)
            -> BaseBuilder
        {
            config.requiredIndicatorTextColor = color
            return self
        }
        
        /// Get config.
        ///
        /// - Returns: A ViewBuilderConfigType instance.
        public func build() -> ViewBuilderConfigType {
            return config
        }
    }
}

extension InputViewBuilderConfig: InputViewIdentifierType {}
extension InputViewBuilderConfig: ViewBuilderConfigType {}
