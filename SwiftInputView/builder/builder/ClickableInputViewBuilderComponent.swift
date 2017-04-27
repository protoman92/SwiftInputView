//
//  ClickableInputViewBuilderComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/27/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import UIKit

/// Use this component to construct clickable inputs, e.g. choice-based whereby
/// a dialog of choices are displayed once the user clicks on the input view.
open class ClickableInputViewBuilderComponent: TextInputViewBuilderComponent {
    
    /// Override this function to provide component for a UIButton.
    ///
    /// - Parameters:
    ///   - view: A parent subview instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType instances.
    override open func builderComponents(for view: UIView,
                                         using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        var components = super.builderComponents(for: view, using: input)
        components.append(button(for: view, using: input))
        return components
    }
    
    /// Create a UIButton for the current parent subview.
    ///
    /// - Parameters:
    ///   - view: A parent subview instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: A ViewBuilderComponentType instance
    open func button(for view: UIView, using input: InputViewDetailType)
        -> ViewBuilderComponentType
    {
        let button = UIBaseButton()
        
        button.accessibilityIdentifier = clickableButtonId
        
        let constraints = FitConstraintSet
            .fit(forParent: view, andChild: button)
            .constraints
        
        return ViewBuilderComponent.builder()
            .with(view: button)
            .with(constraints: constraints)
            .build()
    }
}

extension ClickableInputViewBuilderComponent: ClickableInputViewIdentifierType {}
