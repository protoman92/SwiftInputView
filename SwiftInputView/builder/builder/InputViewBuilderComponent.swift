//
//  InputViewBuilderComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import SwiftUtilities

/// Implement this protocol to build for each input, i.e. Each 
/// InputViewBuilderType (which contains an Array of InputViewDetailType)
/// will execute a series of InputViewBuilderComponentType to set up each
/// InputViewDetailType.
///
/// Using this strategy, even if an input view has multiple inputs, each of
/// those inputs will still be individually configured. For e.g., we can
/// put a choice input and a text input in the same master view.
public protocol InputViewBuilderComponentType: ViewBuilderType {
    init(with: InputViewDetailType)
    
    var input: InputViewDetailType { get }
    
    /// Create an Array of ViewBuilderComponentType for a specific input.
    ///
    /// - Parameters:
    ///   - view: A UIView instance.
    ///   - input: An InputViewDetailType instance.
    /// - Returns: An Array of ViewBuilderComponentType.
    func builderComponents(for view: UIView, using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
}

open class InputViewBuilderComponent {
    public let input: InputViewDetailType
    
    public required init(with input: InputViewDetailType) {
        self.input = input
    }
    
    open func builderComponents(for view: UIView,
                                using input: InputViewDetailType)
        -> [ViewBuilderComponentType]
    {
        return []
    }
}

extension InputViewBuilderComponent: InputViewIdentifierType {}

extension InputViewBuilderComponent: InputViewBuilderComponentType {
    open func builderComponents(for view: UIView) -> [ViewBuilderComponentType] {
        return builderComponents(for: view, using: input)
    }
}
