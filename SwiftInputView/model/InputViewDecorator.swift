//
//  InputViewDecorator.swift
//  SwiftInputView
//
//  Created by Hai Pham on 4/23/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

/// Implement this protocol to provide appearance configurations for input
/// view.
@objc public protocol InputViewDecoratorType {
    
    /// This spacing determines how far apart each parent subview should be
    /// from each other.
    @objc optional var horizontalSpacing: CGFloat { get }
    
    /// Corner radius for each component view.
    @objc optional var inputCornerRadius: CGFloat { get }
    
    /// Background color for each component view.
    @objc optional var inputBackgroundColor: UIColor { get }
}
