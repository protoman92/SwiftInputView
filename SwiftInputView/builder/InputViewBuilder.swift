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
    var inputs: [InputViewDetailType] { get }
}

/// Base class for building InputView.
open class InputViewBuilder {
    
    /// Use this InputViewDetailType Array to construct builder components.
    open let inputs: [InputViewDetailType]
    
    /// We are not using Builder with this class since we expect subclasses
    /// to accept only one argument.
    ///
    /// - Parameter inputs: An Array of InputViewDetailType.
    public init(from inputs: [InputViewDetailType]) {
        self.inputs = inputs
    }
    
    /// Construct with only one InputViewDetailType.
    ///
    /// - Parameter input: An InputViewDetailType instance.
    public convenience init(with input: InputViewDetailType) {
        self.init(from: [input])
    }
    
    /// To accommodate multiple inputs on one line (e.g. first name/last name),
    /// we construct a separate UIView for each input (called parent subviews),
    /// and lay them horizontally.
    ///
    /// - Parameter view: The master UIView.
    /// - Returns: An Array of ViewBuilderComponentType.
    open func builderComponents(for view: UIView) -> [ViewBuilderComponentType] {
        let inputs = self.inputs
        let count = inputs.count
        
        /// If there is only one input, use the master UIView directly.
        if count == 1, let input = inputs.first {
            return builderComponents(forParentSubview: view, using: input)
        }
        
        var components = [ViewBuilderComponentType]()
        let subviews = Array(repeating: {_ in UIView()}, for: count)
        
        // Get sum of concrete inputViewWidth. For inputs that do not specify
        // a width, we anchor their width to a fraction of the master view 
        // minus this value.
        let inputWidths = inputs.flatMap({$0.inputViewWidth})
        let concreteWidth = inputWidths.reduce(0, +)
        
        for (index, (subview, input)) in zip(subviews, inputs).enumerated() {
            let identifier = parentSubviewId(for: index + 1)
            let psc = builderComponents(forParentSubview: subview, using: input)
            
            subview.accessibilityIdentifier = identifier
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
            
            // Left constraint for parent subview. If this is the first
            // subview to be added, the previousView will be the parent view,
            // and the second attribute will be .left.
            let previousView = index == 0 ? view : subviews[index - 1]
            let secondAttr = index == 0 ? NSLayoutAttribute.left : .right
            
            let left = BaseLayoutConstraint(item: subview,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: previousView,
                                            attribute: secondAttr,
                                            multiplier: 1,
                                            constant: 0)
            
            left.constantValue = String(describing: 0)
            left.identifier = parentSubviewLeftId
            
            // Width constraint for parent subview. We need to divide the
            // width by the number of subviews, or set a concrete width if
            // necessary.
            let width: BaseLayoutConstraint
            
            if let concreteValue = inputWidths.element(at: index) {
                
                // Direct width constraint.
                width = BaseLayoutConstraint(item: subview,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1,
                                             constant: concreteValue)
                
                width.identifier = parentSubviewWidthId
            } else {
                // Since concrete widths are already set, we subtract their
                // count to calculate the multiplier.
                let ratio = 1 / CGFloat(count - inputWidths.count)
                let constant: CGFloat = -(concreteWidth * ratio)
                
                width = BaseLayoutConstraint(item: subview,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: view,
                                             attribute: .width,
                                             multiplier: ratio,
                                             constant: constant)
                
                width.constantValue = String(describing: -1)
                width.identifier = parentSubviewWidthRatioId
            }
            
            // Construct builder component for parent subview. With these
            // constraints, all parent subviews should be laid side by side.
            components.append(ViewBuilderComponent.builder()
                .with(view: subview)
                .add(constraint: top)
                .add(constraint: bottom)
                .add(constraint: left)
                .add(constraint: width)
                .build())
        }
        
        return components
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
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType instance.
    open func builderComponents(forParentSubview view: UIView,
                                using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        let indicator = requiredIndicator(for: view, using: input)
        return [indicator]
    }

    /// Return a component for the required indicator.
    ///
    /// - Parameters:
    ///   - view: The parent UIView.
    ///   - input: An InputViewDetailType instance.
    ///   - others: Other UIView on which this view may depend.
    /// - Returns: A ViewBuilderComponentType instance.
    open func requiredIndicator(for view: UIView,
                                using input: InputViewDetailType,
                                dependingOn others: UIView...)
        -> ViewBuilderComponentType
    {
        if !input.isRequired {
            return ViewBuilderComponent.empty
        }
        
        let indicator = BaseLabel()
        indicator.accessibilityIdentifier = requiredIndicatorId
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
    
    /// This spacing determines how far apart each parent subview should be
    /// from each other.
    fileprivate var horizontalSpacing: CGFloat
    
    fileprivate var inputCornerRadius: CGFloat
    fileprivate var inputBackgroundColor: UIColor
    fileprivate var requiredIndicatorTextColor: UIColor
    
    init() {
        horizontalSpacing = Space.smaller.value ?? 0
        inputCornerRadius = Space.small.value ?? 0
        inputBackgroundColor = .clear
        requiredIndicatorTextColor = .red
    }
    
    /// If there are multiple inputs, find all parent subviews and configure
    /// them individually.
    ///
    /// - Parameter view: The master UIView.
    public func configure(for view: UIView) {
        let baseIdentifier = parentSubviewId
        
        let parentSubviews = view.findAll(withBaseIdentifier: baseIdentifier,
                                          andStartingIndex: 1)
        
        if parentSubviews.isNotEmpty {
            configureConstraints(forMasterView: view,
                                 andParentSubviews: parentSubviews)
            
            parentSubviews.forEach({self.configure(forParentSubview: $0)})
        } else {
            configure(forParentSubview: view)
        }
    }
    
    /// In case there are multiple inputs, we need to find all parent subviews
    /// and configure them individually. If there is only one, we can call
    /// this method directly on the master UIView.
    ///
    /// - Parameter view: A UIView instance.
    open func configure(forParentSubview view: UIView) {
        
        // Configure the parent subview.
        view.backgroundColor = inputBackgroundColor
        view.layer.cornerRadius = inputCornerRadius
        
        // Configure the child views.
        let subviews = view.subviews
        
        guard let requiredIndicator = subviews.filter({
            $0.accessibilityIdentifier == requiredIndicatorId
        }).first as? UILabel else {
            return
        }
        
        configure(requiredInput: requiredIndicator)
    }
    
    /// Configure constraints for each parent subview.
    ///
    /// - Parameters:
    ///   - view: The master UIView.
    ///   - subs: An Array of all parent subviews.
    fileprivate func configureConstraints(forMasterView view: UIView,
                                          andParentSubviews subs: [UIView]) {
        let horizontalSpacing = self.horizontalSpacing
        
        // We include all parent subviews' constraints to access their direct
        // width constraints, if applicable.
        let constraints = view.constraints + subs.flatMap({$0.constraints})
        
        // We skip the first subview since it should be anchored to the left
        // of the master view.
        constraints.filter({
            $0.identifier == self.parentSubviewLeftId &&
            $0.secondAttribute == .right
        }).forEach({$0.constant = horizontalSpacing})
        
        // Reduce width to fit the parent view, since we added a horizontal
        // spacing above. Only do this for relative width constraint, not
        // direct width (i.e. inputs that have explicit widths)
        let concreteWidthCount = constraints.filter({
            $0.identifier == self.parentSubviewWidthId
        }).count
        
        let subCount = subs.count
        let nonConcrete = Swift.max(subCount - concreteWidthCount, 1)
        let multiplier = (CGFloat(subCount - 1)) / CGFloat(nonConcrete)
        let offset = horizontalSpacing * multiplier
        
        constraints.filter({
            $0.identifier == self.parentSubviewWidthRatioId
        }).forEach({$0.constant -= offset})
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
        
        /// Set horizontalSpacing.
        ///
        /// - Parameter spacing: A CGFloat value.
        /// - Returns: The current Builder
        public func with(horizontalSpacing spacing: CGFloat) -> BaseBuilder {
            config.horizontalSpacing = spacing
            return self
        }
        
        /// Set inputCornerRadius.
        ///
        /// - Parameter spacing: A CGFloat value.
        /// - Returns: The current Builder
        public func with(inputCornerRadius radius: CGFloat) -> BaseBuilder {
            config.inputCornerRadius = radius
            return self
        }
        
        /// Set the input backgroundColor.
        ///
        /// - Parameter color: A UIColor instance.
        /// - Returns: The current Builder instance.
        public func with(inputBackgroundColor color: UIColor) -> BaseBuilder {
            config.inputBackgroundColor = color
            return self
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
