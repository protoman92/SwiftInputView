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

/// Protocol for input view builder config.
public protocol InputViewBuilderConfigType: ViewBuilderConfigType {
    init<S: Sequence>(from decorators: S)
        where S.Iterator.Element: InputViewDecoratorType
    
    init<S: Sequence>(from decorators: S)
        where S.Iterator.Element == InputViewDecoratorType
    
    /// These decorator instances contain the information needed to change
    /// view appearances. There should be one decorator for each parent
    /// subview.
    ///
    /// Usually, we can make enum instances that implement InputViewDetailType
    /// to implement InputViewDecoratorType as well, so that each input can
    /// customize its own appearance.
    var decorators: [InputViewDecoratorType] { get }
}

/// Configure dynamic subviews for InputView.
open class InputViewBuilderConfig {
    public let decorators: [InputViewDecoratorType]
    
    /// We are not using Builder with this class since we expect subclasses
    /// to accept only one argument.
    ///
    /// - Parameter inputs: An Sequence of InputViewDecoratorType subclass.
    public required init<S: Sequence>(from decorators: S)
        where S.Iterator.Element: InputViewDecoratorType
    {
        self.decorators = decorators.map(eq)
    }
    
    /// Construct with a Sequence of InputViewDecoratorType.
    ///
    /// - Parameter inputs: A Sequence of InputViewDecoratorType.
    public required init<S: Sequence>(from decorators: S)
        where S.Iterator.Element == InputViewDecoratorType
    {
        self.decorators = decorators.map(eq)
    }
    
    /// Construct with only one InputViewDecoratorType.
    ///
    /// - Parameter input: An InputViewDecoratorType instance.
    public convenience init(with input: InputViewDecoratorType) {
        self.init(from: [input])
    }
    
    public convenience init(with value: Any) {
        if let value = value as? InputViewDecoratorType {
            self.init(with: value)
        } else if let value = value as? [InputViewDecoratorType] {
            self.init(from: value)
        } else {
            debugException()
            self.init(from: [])
        }
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
            
            for (index, subview) in parentSubviews.enumerated() {
                guard let decorator = decorators.element(at: index) else {
                    continue
                }
                
                decorator.configComponent().configure(for: subview)
            }
        } else if let decorator = decorators.first {
            decorator.configComponent().configure(for: view)
        }
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
}

extension InputViewBuilderConfig {
    
    /// We only take the largest horizontal spacing. Usually this value is
    /// constant for all decorator instances.
    var horizontalSpacing: CGFloat {
        let spacing = decorators.flatMap({$0.horizontalSpacing}).max()
        return (spacing ?? Space.smaller.value) ?? 0
    }
}

extension InputViewBuilderConfig: InputViewIdentifierType {}
extension InputViewBuilderConfig: InputViewBuilderConfigType {}
