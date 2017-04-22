//
//  InputViewBuilderConfig.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/23/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftUtilities
import SwiftUIUtilities

/// Configure dynamic subviews for InputView.
open class InputViewBuilderConfig {
    
    /// This decorator instance contains the information needed to change
    /// view appearances.
    var decorator: InputViewDecoratorType?
    
    init() {}
    
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
            
            parentSubviews.forEach({
                self.configureAppearance(forParentSubview: $0)
                self.configureLogic(forParentSubview: $0)
            })
        } else {
            configureAppearance(forParentSubview: view)
            configureLogic(forParentSubview: view)
        }
    }
    
    /// In case there are multiple inputs, we need to find all parent subviews
    /// and configure them individually. If there is only one, we can call
    /// this method directly on the master UIView.
    ///
    /// This method only configures the view's appearance.
    ///
    /// - Parameter view: A UIView instance.
    open func configureAppearance(forParentSubview view: UIView) {
        
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
    
    /// Configure business logic for a parent subview, or the master view if
    /// there is only one input.
    ///
    /// - Parameter view: A UIView instance.
    open func configureLogic(forParentSubview view: UIView) {}
    
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
        
        /// Set decorator.
        ///
        /// - Parameter decorator: A InputViewDecoratorType instance.
        /// - Returns: The current Builder
        public func with(decorator: InputViewDecoratorType) -> BaseBuilder {
            config.decorator = decorator
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

extension InputViewBuilderConfig: InputViewDecoratorType {
    public var horizontalSpacing: CGFloat {
        return (decorator?.horizontalSpacing ?? Space.small.value) ?? 0
    }
    
    public var inputCornerRadius: CGFloat {
        return (decorator?.inputCornerRadius ?? Space.small.value) ?? 0
    }
    
    public var inputBackgroundColor: UIColor {
        return decorator?.inputBackgroundColor ?? .clear
    }
    
    public var requiredIndicatorTextColor: UIColor {
        return decorator?.requiredIndicatorTextColor ?? .red
    }

}

extension InputViewBuilderConfig: InputViewIdentifierType {}
extension InputViewBuilderConfig: ViewBuilderConfigType {}
