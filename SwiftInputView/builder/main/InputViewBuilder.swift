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
    init(from inputs: [InputViewDetailType])
    
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
    public required init(from inputs: [InputViewDetailType]) {
        self.inputs = inputs
    }
    
    /// Construct with only one InputViewDetailType.
    ///
    /// - Parameter input: An InputViewDetailType instance.
    public convenience init(with input: InputViewDetailType) {
        self.init(from: [input])
    }
    
    /// Return nil if the value is neither an InputViewDetailType instance
    /// nor an Array of that type.
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
            return input.viewBuilderComponent().builderComponents(for: view)
        }
        
        var components = [ViewBuilderComponentType]()
        let subs = Array(repeating: {_ in UIInputComponentView()}, for: count)
        
        // Get sum of concrete inputViewWidth. For inputs that do not specify
        // a width, we anchor their width to a fraction of the master view 
        // minus this value.
        let inputWidths = inputs.flatMap({$0.inputViewWidth})
        let concreteWidth = inputWidths.reduce(0, +)
        
        for (index, (subview, input)) in zip(subs, inputs).enumerated() {
            let identifier = parentSubviewId(for: index + 1)
            let builderComponent = input.viewBuilderComponent()
            let psc = builderComponent.builderComponents(for: subview)
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
            let previousView = index == 0 ? view : subs[index - 1]
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
            
            if let concreteValue = input.inputViewWidth {
                
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
}

extension InputViewBuilder: InputViewIdentifierType {}
extension InputViewBuilder: InputViewBuilderType {}
