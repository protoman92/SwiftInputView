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
    var inputs: [InputDetailType] { get }
}

/// Base class for building InputView.
open class InputViewBuilder {
    
    /// Use this InputDetailType Array to construct builder components.
    open let inputs: [InputDetailType]
    
    /// We are not using Builder with this class since we expect subclasses
    /// to accept only one argument.
    ///
    /// - Parameter inputs: A Sequence of InputDetailType.
    public init<S: Sequence>(with inputs: S)
        where S.Iterator.Element: InputDetailType
    {
        self.inputs = inputs.map(eq)
    }
    
    /// To accommodate multiple inputs on one line (e.g. first name/last name),
    /// we construct a separate UIView for each input (called parent subviews),
    /// and lay them horizontally.
    ///
    /// - Parameter view: The master UIView.
    /// - Returns: An Array of ViewBuilderComponentType.
    open func builderComponents(for view: UIView) -> [ViewBuilderComponentType] {
        var components = [ViewBuilderComponentType]()
        let inputs = self.inputs
        let count = inputs.count
        
        let subviews = inputs.map({
            self.parentSubview(for: view, using: $0, basedOn: inputs)
        })
        
        for (index, (subview, input)) in zip(subviews, inputs).enumerated() {
            let psc = builderComponents(forParentSubview: subview, using: input)
            subview.populateSubviews(from: psc)
            
            // Top constraint for parent subview.
            let top = BaseLayoutConstraint(item: subview,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .top,
                                           multiplier: 1,
                                           constant: 0)
            
            top.constantValue = String(describing: 0)
            
            // Bottom constraint for parent subview.
            let bottom = BaseLayoutConstraint(item: view,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: subview,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0)
            
            bottom.constantValue = String(describing: 0)
            
            // Left constraint for parent subview
            let previousView = index == 0 ? view : subviews[index - 1]
            
            let left = BaseLayoutConstraint(item: view,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: previousView,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: 0)
            
            left.constantValue = String(describing: 0)
            
            // Width constraint for parent subview. We need to divide the
            // width by the number of subviews.
            let width = BaseLayoutConstraint(item: subview,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: view,
                                             attribute: .width,
                                             multiplier: 1 / CGFloat(count),
                                             constant: 0)
            
            width.constantValue = String(describing: 0)
            
            // Construct builder component for parent subview. With these
            // constraints, all parent subviews should be laid side by side.
            let svc = ViewBuilderComponent.builder()
                .with(view: subview)
                .add(constraint: top)
                .add(constraint: bottom)
                .add(constraint: left)
                .add(constraint: width)
                .build()
            
            components.append(svc)
        }
        
        return components
    }
    
    /// Create a parent subview. If there is only one input, use the master
    /// UIView directly.
    ///
    /// - Parameters:
    ///   - view: The parent UIView.
    ///   - input: An InputDetailType instance.
    ///   - inputs: An Array of InputDetailType.
    /// - Returns: A UIView instance.
    fileprivate func parentSubview(for view: UIView,
                                   using input: InputDetailType,
                                   basedOn inputs: [InputDetailType])
        -> UIView
    {
        if inputs.count == 1 {
            return view
        } else {
            return UIView()
        }
    }
    
    /// Get an Array of ViewBuilderComponentType for the parent subview.
    ///
    /// For each input, we inflate a UIView and attach it to the master UIView
    /// by laying them side by side, horizontally. This allows us to have
    /// multiple inputs on the same line.
    ///
    /// If there is only one input, use the master view directly.
    ///
    /// - Parameters:
    ///   - view: The parent subview UIView.
    ///   - input: An InputDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType instance.
    open func builderComponents(forParentSubview view: UIView,
                                using input: InputDetailType)
        -> [ViewBuilderComponentType]
    {
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
