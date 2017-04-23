//
//  InputViewDecoratorType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/23/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

/// Implement this protocol to provide appearance configurations for input
/// view.
public protocol InputViewDecoratorType {
    /// This spacing determines how far apart each parent subview should be
    /// from each other.
    var horizontalSpacing: CGFloat? { get }
    
    /// Corner radius for each component view.
    var inputCornerRadius: CGFloat? { get }
    
    /// Background color for each component view.
    var inputBackgroundColor: UIColor? { get }
    
    /// Get a InputViewConfigComponentType type to dynamically construct a
    /// config instance.
    var configComponentType: InputViewConfigComponentType.Type { get }
}

public extension InputViewDecoratorType {
    
    /// Create an InputViewConfigComponentType instance.
    ///
    /// - Returns: An InputViewConfigComponentType instance.
    public func configComponent() -> InputViewConfigComponentType {
        return configComponentType.init(with: self)
    }
}
