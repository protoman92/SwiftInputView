//
//  InputViewDecoratorType.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/23/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

/// Implement this protocol to provide appearance configurations for input
/// view. These properties are optional, such that we can omit certain
/// values and the builder config will fall back to default values.
@objc public protocol InputViewDecoratorType {
    /// This spacing determines how far apart each parent subview should be
    /// from each other.
    @objc optional var horizontalSpacing: CGFloat { get }
    
    /// Corner radius for each component view.
    @objc optional var inputCornerRadius: CGFloat { get }
    
    /// Background color for each component view.
    @objc optional var inputBackgroundColor: UIColor { get }
}

/// Implement this protocol to provide appearance configurations for 
/// text-based input view.
@objc public protocol TextInputViewDecoratorType: InputViewDecoratorType {
    
    /// Required indicator text color for each component view.
    @objc optional var requiredIndicatorTextColor: UIColor { get }
    
    /// Text color for inputField.
    @objc optional var inputTextColor: UIColor { get }
    
    /// Tint color for inputField.
    @objc optional var inputTintColor: UIColor { get }
    
    /// Text color for placeholder.
    @objc optional var placeholderTextColor: UIColor { get }
}
