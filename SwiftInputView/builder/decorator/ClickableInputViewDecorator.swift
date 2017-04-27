//
//  ClickableInputViewDecorator.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/27/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import UIKit

@objc public protocol ClickableInputViewDecoratorType: TextInputViewDecoratorType {
    
    /// Get the font name to pass to button. Use a default value if this
    /// returns nil.
    @objc optional var buttonFontName: String { get }
    
    /// Get the font size to pass to button. Use a default value if this
    /// returns nil.
    @objc optional var buttonFontSize: CGFloat { get }
}

public extension ClickableInputViewDecoratorType {
    
    /// Get the font instance to pass to button.
    public var buttonFont: UIFont? {
        let fontName = buttonFontName ?? DefaultFont.normal.value
        let fontSize = buttonFontSize ?? TextSize.medium.value ?? 0
        return UIFont(name: fontName, size: fontSize)
    }
}
