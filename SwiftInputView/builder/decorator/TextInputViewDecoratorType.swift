//
//  TextInputViewDecoratorType.swift
//  TestApplication
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

/// Implement this protocol to provide appearance configurations for text-based 
/// input view.
public protocol TextInputViewDecoratorType: InputViewDecoratorType {
    
    /// Required indicator text color for each component view.
    var requiredIndicatorTextColor: UIColor? { get }
    
    /// Set a custom required indicator text.
    var requiredIndicatorText: String? { get }
    
    var inputTextAlignment: NSTextAlignment? { get }
    
    /// Text color for inputField.
    var inputTextColor: UIColor? { get }
    
    /// Tint color for inputField.
    var inputTintColor: UIColor? { get }
    
    /// Text color for placeholder.
    var placeholderTextColor: UIColor? { get }
}
