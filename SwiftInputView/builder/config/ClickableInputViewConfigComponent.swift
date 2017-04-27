//
//  ClickableInputViewConfigComponent.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/27/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import SwiftUIUtilities
import UIKit

/// Configure clickable inputs (i.e. choice-based)
open class ClickableInputViewConfigComponent: TextInputViewConfigComponent {
    override open func configureAppearance(for view: UIView) {
        super.configureAppearance(for: view)
        let subviews = view.subviews
        
        if let button = subviews.filter({
            $0.accessibilityIdentifier == clickableButtonId
        }).first as? UIButton {
            configure(button: button)
        }
    }
    
    /// Configure the clickable button.
    ///
    /// - Parameter button: A UIButton instance.
    open func configure(button: UIButton) {
        button.backgroundColor = .clear
        button.titleLabel?.textColor = .clear
        button.titleLabel?.font = buttonFont
    }
}

extension ClickableInputViewConfigComponent: ClickableInputViewIdentifierType {}

extension ClickableInputViewConfigComponent: ClickableInputViewDecoratorType {
    
    /// Optionally cast the decorator to ClickableInputViewDecoratorType.
    var clickableDecorator: ClickableInputViewDecoratorType? {
        return decorator as? ClickableInputViewDecoratorType
    }

    public var buttonFontName: String {
        return clickableDecorator?.buttonFontName ?? DefaultFont.normal.value
    }
    
    public var buttonFontSize: CGFloat {
        return clickableDecorator?.buttonFontSize ?? TextSize.medium.value ?? 0
    }
}
