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
}

/// Implement this protocol to provide appearance configurations for 
/// text-based input view.
public protocol TextInputViewDecoratorType: InputViewDecoratorType {
    
    /// Required indicator text color for each component view.
    var requiredIndicatorTextColor: UIColor? { get }
    
    var inputTextAlignment: NSTextAlignment? { get }
    
    /// Text color for inputField.
    var inputTextColor: UIColor? { get }
    
    /// Tint color for inputField.
    var inputTintColor: UIColor? { get }
    
    /// Text color for placeholder.
    var placeholderTextColor: UIColor? { get }
}
