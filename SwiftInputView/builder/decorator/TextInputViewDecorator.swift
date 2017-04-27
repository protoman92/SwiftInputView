//
//  TextInputViewDecorator.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/24/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import UIKit

/// Implement this protocol to provide appearance configurations for text-based 
/// input view.
@objc public protocol TextInputViewDecoratorType: InputViewDecoratorType {
    
    /// Get the font name to pass to inputField. Use a default value if this
    /// returns nil.
    @objc optional var inputFieldFontName: String { get }
    
    /// Get the font size to pass to inputField. Use a default value if this
    /// returns nil.
    @objc optional var inputFieldFontSize: CGFloat { get }
    
    /// Check if the inputField requires input mask (e.g. password field).
    /// Defaults to false.
    @objc optional var isSecureTextEntry: Bool { get }
    
    /// Get the font name to pass to required indicator. Use a default value 
    /// if this returns nil.
    @objc optional var requiredIndicatorFontName: String { get }
    
    /// Get the font size to pass to required indicator. Use a default value 
    /// if this returns nil.
    @objc optional var requiredIndicatorFontSize: CGFloat { get }
    
    /// Required indicator text color for each component view.
    @objc optional var requiredIndicatorTextColor: UIColor { get }
    
    /// Set a custom required indicator text.
    @objc optional var requiredIndicatorText: String { get }
    
    /// Get the text alignment for the inputField.
    @objc optional var inputTextAlignment: NSTextAlignment { get }
    
    /// Text color for inputField.
    @objc optional var inputTextColor: UIColor { get }
    
    /// Tint color for inputField.
    @objc optional var inputTintColor: UIColor { get }
    
    /// Text color for placeholder.
    @objc optional var placeholderTextColor: UIColor { get }
}

public extension TextInputViewDecoratorType {
    
    /// Get the font instance to pass to inputField.
    public var inputFieldFont: UIFont? {
        let fontName = inputFieldFontName ?? DefaultFont.normal.value
        let fontSize = inputFieldFontSize ?? TextSize.medium.value ?? 0
        return UIFont(name: fontName, size: fontSize)
    }
    
    /// Get the font instance to pass to required indicator.
    public var requiredIndicatorFont: UIFont? {
        let fontName = requiredIndicatorFontName ?? DefaultFont.normal.value
        let fontSize = requiredIndicatorFontSize ?? TextSize.small.value ?? 0
        return UIFont(name: fontName, size: fontSize)
    }
}
