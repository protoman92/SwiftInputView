//
//  InputViewBuilder.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/21/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftBaseViews
import SwiftUtilities
import SwiftUIUtilities

/// Protocol for input view builder.
public protocol InputViewBuilderType: ViewBuilderType {
    
    init<S: Sequence>(from inputs: S) where S.Iterator.Element: InputViewDetailType
    
    init<S: Sequence>(from inputs: S) where S.Iterator.Element == InputViewDetailType
    
    var inputs: [InputViewDetailType] { get }
}

/// Base class for building InputView.
open class InputViewBuilder {
    
    /// Use this InputViewDetailType Array to construct builder components.
    open let inputs: [InputViewDetailType]
    
    /// We are not using Builder with this class since we expect subclasses
    /// to accept only one argument.
    ///
    /// - Parameter inputs: A Sequence of InputViewDetailType subclass.
    public required init<S: Sequence>(from inputs: S)
        where S.Iterator.Element: InputViewDetailType
    {
        self.inputs = inputs.map(eq)
    }
    
    /// Construct with a Sequence of InputViewDetailType.
    ///
    /// - Parameter inputs: A Sequence of InputViewDetailType.
    public required init<S: Sequence>(from inputs: S)
        where S.Iterator.Element == InputViewDetailType
    {
        self.inputs = inputs.map(eq)
    }
    
    /// Construct with only one InputViewDetailType.
    ///
    /// - Parameter input: An InputViewDetailType instance.
    public convenience init(with input: InputViewDetailType) {
        self.init(from: [input])
    }
    
    /// Construct with an Any object, but we need to detect its actual type 
    /// first.
    ///
    /// - Parameter value: An object of type Any.
    public convenience init(with value: Any) {
        if let value = value as? InputViewDetailType {
            self.init(with: value)
        } else if let value = value as? [InputViewDetailType] {
            self.init(from: value)
        } else {
            debugException()
            self.init(from: [])
        }
    }
    
    // MARK: ViewBuilderType

    /// To accommodate multiple inputs on one line (e.g. first name/last name),
    /// we construct a separate UIView for each input (called parent subviews),
    /// and lay them horizontally.
    ///
    /// - Returns: An Array of ViewBuilderComponentType.
    open func subviews(for view: UIView) -> [UIView] {
        let inputs = self.inputs
        let count = inputs.count
        
        if count > 1 {
            let closure: (Int) -> UIView = {_ in UIInputComponentView()}
            let subviews = Array(repeating: closure, for: count)
            
            for (index, subview) in subviews.enumerated() {
                if let input = inputs.element(at: index) {
                    let builder = input.viewBuilderComponent()
                    let identifier = parentSubviewId(for: index + 1)
                    subview.accessibilityIdentifier = identifier
                    subview.populateSubviews(with: builder)
                }
            }
            
            return subviews
        } else if let input = inputs.first {
            return input.viewBuilderComponent().subviews(for: view)
        }
        
        return []
    }
    
    /// Get an Array of NSLayoutConstraint to be added to a UIView.
    ///
    /// - Parameter view: The parent UIView instance.
    /// - Returns: An Array of NSLayoutConstraint.
    open func constraints(for view: UIView) -> [NSLayoutConstraint] {
        let subviews = view.subviews
        let count = inputs.count
        
        if count == 1, let input = inputs.first {
            return input.viewBuilderComponent().constraints(for: view)
        }
        
        // Get sum of concrete inputViewWidth. For inputs that do not specify
        // a width, we anchor their width to a fraction of the master view
        // minus this value.
        let widths = inputs.flatMap({$0.inputWidth}).filter({$0 > 0})
        let concreteWidth = widths.reduce(0, +)
        
        var constraints = [NSLayoutConstraint]()
        
        for (index, input) in inputs.enumerated() {
            let identifier = parentSubviewId(for: index + 1)
            
            guard let subview = subviews.filter({
                $0.accessibilityIdentifier == identifier
            }).first else {
                continue
            }
            
            // Top constraint for parent subview.
            let top = NSBaseLayoutConstraint(item: subview,
                                             attribute: .top,
                                             relatedBy: .equal,
                                             toItem: view,
                                             attribute: .top,
                                             multiplier: 1,
                                             constant: 0)
            
            top.constantValue = String(describing: 0)
            
            // Bottom constraint for parent subview.
            let bottom = NSBaseLayoutConstraint(item: view,
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
            //
            // We check this by finding a UIView that has an identifier with 
            // postfix count less than the current count.
            let previousIdentifier = parentSubviewId(for: index)
            
            let previousView: UIView
            let secondAttr: NSLayoutAttribute
            
            if let psv = subviews.filter({
                $0.accessibilityIdentifier == previousIdentifier
            }).first {
                previousView = psv
                secondAttr = .right
            } else {
                // In this case, this subview is the first.
                previousView = view
                secondAttr = .left
            }
            
            let left = NSBaseLayoutConstraint(item: subview,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: previousView,
                                              attribute: secondAttr,
                                              multiplier: 1,
                                              constant: 0)
            
            left.constantValue = String(describing: 0)
            left.identifier = self.parentSubviewLeftId
            
            // Width constraint for parent subview. We need to divide the
            // width by the number of subviews, or set a concrete width if
            // necessary.
            let width: NSBaseLayoutConstraint
            
            if let vWidth = input.inputWidth, vWidth > 0 {
                
                // Direct width constraint.
                width = NSBaseLayoutConstraint(item: subview,
                                               attribute: .width,
                                               relatedBy: .equal,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 1,
                                               constant: vWidth)
                
                width.identifier = self.parentSubviewWidthId
            } else {
                // Since concrete widths are already set, we subtract their
                // count to calculate the multiplier.
                let ratio = 1 / CGFloat(count - widths.count)
                let constant: CGFloat = -(concreteWidth * ratio)
                
                width = NSBaseLayoutConstraint(item: subview,
                                               attribute: .width,
                                               relatedBy: .equal,
                                               toItem: view,
                                               attribute: .width,
                                               multiplier: ratio,
                                               constant: constant)
                
                width.constantValue = String(describing: -1)
                width.identifier = self.parentSubviewWidthRatioId
            }
            
            constraints.append(top)
            constraints.append(left)
            constraints.append(bottom)
            constraints.append(width)
        }
        
        return constraints
    }
}

// MARK: - ViewBuilderConfigType.
extension InputViewBuilder {
    
    /// We only take the largest horizontal spacing. Usually this value is
    /// constant for all decorator instances.
    var horizontalSpacing: CGFloat {
        let spacing = inputs.flatMap({$0.decorator.horizontalSpacing}).max()
        return (spacing ?? Space.smaller.value) ?? 0
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
            configureConstraints(for: view, and: parentSubviews)
            
            for (index, subview) in parentSubviews.enumerated() {
                if let input = inputs.element(at: index) {
                    input.viewBuilderComponent().configure(for: subview)
                }
            }
        } else if let input = inputs.first {
            input.viewBuilderComponent().configure(for: view)
        }
    }
    
    /// Configure constraints for each parent subview.
    ///
    /// - Parameters:
    ///   - view: The master UIView.
    ///   - subs: An Array of all parent subviews.
    func configureConstraints(for view: UIView, and subs: [UIView]) {
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

extension InputViewBuilder: InputViewIdentifierType {}
extension InputViewBuilder: InputViewBuilderType {}
