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
    
    /// These decorator instances contain the information needed to change
    /// view appearances. There should be one decorator for each parent 
    /// subview.
    ///
    /// Usually, we can make enum instances that implement InputViewDetailType 
    /// to implement InputViewDecoratorType as well, so that each input can
    /// customize its own appearance.
    var decorators: [InputViewDecoratorType]
    
    init() { decorators = [] }
    
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
            
            for (index, subview) in parentSubviews.enumerated() {
                configureAppearance(forParentSubview: subview, at: index)
                configureLogic(forParentSubview: subview)
            }
        } else {
            configureAppearance(forParentSubview: view, at: 0)
            configureLogic(forParentSubview: view)
        }
    }
    
    /// In case there are multiple inputs, we need to find all parent subviews
    /// and configure them individually. If there is only one, we can call
    /// this method directly on the master UIView.
    ///
    /// This method only configures the view's appearance.
    ///
    /// - Parameters:
    ///   - view: The master UIView.
    ///   - index: The index of the parent subview.
    open func configureAppearance(forParentSubview view: UIView, at index: Int) {
        
        // Configure the parent subview.
        view.backgroundColor = inputBackgroundColor(for: index)
        view.layer.cornerRadius = inputCornerRadius(for: index)
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
        
        /// Add a decorator.
        ///
        /// - Parameter decorator: A InputViewDecoratorType instance.
        /// - Returns: The current Builder instance.
        public func add(decorator: InputViewDecoratorType) -> BaseBuilder {
            config.decorators.append(decorator)
            return self
        }
        
        /// Add decorators.
        ///
        /// - Parameter decorators: A vararg of InputViewDecoratorType.
        /// - Returns: The current Builder instance.
        public func add(decorators: InputViewDecoratorType...) -> BaseBuilder {
            config.decorators.append(contentsOf: decorators)
            return self
        }
        
        /// Add decorators.
        ///
        /// - Parameter decorators: A Sequence of InputViewDecoratorType.
        /// - Returns: The current Builder instance.
        public func add<S: Sequence>(decorators: S)
            -> BaseBuilder
            where S.Iterator.Element: InputViewDecoratorType
        {
            config.decorators.append(contentsOf: decorators.map(eq))
            return self
        }
        
        /// Set a single decorator.
        ///
        /// - Parameter decorator: An InputViewDecoratorInstance.
        /// - Returns: The current Builder instance.
        public func with(decorator: InputViewDecoratorType) -> BaseBuilder {
            config.decorators = [decorator]
            return self
        }
        
        /// Set decorators.
        ///
        /// - Parameter decorators: A Sequence of InputViewDecoratorType.
        /// - Returns: The current Builder instance.
        public func with<S: Sequence>(decorators: S) -> BaseBuilder
            where S.Iterator.Element: InputViewDecoratorType
        {
            config.decorators = decorators.map(eq)
            return self
        }
        
        /// Set decorators.
        ///
        /// - Parameter decorators: An Array of InputViewDecoratorType.
        /// - Returns: The current Builder instance.
        public func with(decorators: [InputViewDecoratorType]) -> BaseBuilder {
            config.decorators = decorators.map(eq)
            return self
        }
        
        /// Cast and set decorators.
        ///
        /// - Parameter decorators: An object of type Any.
        /// - Returns: The current Builder instance.
        public func with(_ someType: Any) -> BaseBuilder {
            if let item = someType as? InputViewDecoratorType {
                return with(decorator: item)
            } else if let items = someType as? [InputViewDecoratorType] {
                return with(decorators: items)
            }
            
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

extension InputViewBuilderConfig {
    
    /// We only take the largest horizontal spacing. Usually this value is
    /// constant for all decorator instances.
    var horizontalSpacing: CGFloat {
        let spacing = decorators.flatMap({$0.horizontalSpacing}).max()
        return (spacing ?? Space.smaller.value) ?? 0
    }
    
    /// Get input corner radius using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A CGFloat value.
    func inputCornerRadius(for index: Int) -> CGFloat {
        let decorator = decorators.element(at: index)
        return (decorator?.inputCornerRadius ?? Space.small.value) ?? 0
    }
    
    /// Get input background color using a decorator instance.
    ///
    /// - Parameter index: The index at which the decorator is found.
    /// - Returns: A UIColor value.
    func inputBackgroundColor(for index: Int) -> UIColor {
        let decorator = decorators.element(at: index)
        return decorator?.inputBackgroundColor ?? .clear
    }
}

extension InputViewBuilderConfig: InputViewIdentifierType {}
extension InputViewBuilderConfig: ViewBuilderConfigType {}
