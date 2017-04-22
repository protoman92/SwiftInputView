//
//  extension.swift
//  TestApplication
//
//  Created by Hai Pham on 4/22/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import UIKit

extension UIView: IncrementalIdentifierType {
    public typealias Element = UIView
    
    /// We return a UIView subview with accessibilityIdentifier that match the
    /// identifier.
    ///
    /// - Parameter identifier: A String value.
    /// - Returns: An optional UIView instance.
    public func findElement(with identifier: String) -> UIView? {
        return subviews.filter({$0.accessibilityIdentifier == identifier}).first
    }
}
